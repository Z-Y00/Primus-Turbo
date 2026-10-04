###############################################################################
# SPDX-License-Identifier: Apache-2.0
#
# Copyright (c) 2025, Advanced Micro Devices, Inc. All rights reserved.
# Copyright (c) 2025 FlyDSL Project Contributors
#
# Adapted from FlyDSL (https://github.com/ROCm/FlyDSL)
# Modified by the Primus-Turbo team.
#
# This file is distributed under the Apache License 2.0 (see LICENSE-APACHE),
# not the MIT license that covers the rest of Primus-Turbo (see LICENSE).
###############################################################################

"""Flash-attention backward for gfx1250 (MI455X): wave32, v_wmma_f32_16x16x32_bf16.

Companion of ``flash_attn_fwd_gfx1250``; same layouts (packed varlen THD, strided dense
SBHD / BSHD), masking (bottom-right causal, left window), GQA and sink semantics.

Two deterministic kernels, no atomics:

* dK/dV: a workgroup owns ``BLOCK_KV`` key rows and walks every q tile (of every q head in
  its GQA group) that can see them. Lanes own key columns: ``S = Q K^T`` and ``dP = dO V^T``
  come out with one key per lane, which is already the B operand of ``dV^T += dO^T P`` and
  ``dK^T += Q^T dS``; the dO^T / Q^T A operands are ``ds_load_tr16_b128`` reads of the
  staged q tile.
* dQ: a workgroup owns ``BLOCK_Q`` query rows and walks the key tiles, in the forward's
  transposed orientation (``S^T = K Q^T``, ``dQ^T += K^T dS^T``), so the per-row softmax
  statistics are lane-uniform.

Both read ``lse2 = LSE * log2(e)`` (``+inf`` where the forward saw no key, so P is 0 there)
and ``delta = rowsum(dO * O)``, head-major ``[Hq, tokens]`` fp32.
"""

import functools
import math

import flydsl.compiler as flyc
import flydsl.expr as fx
import torch
from flydsl.expr import const_expr, gpu, range_constexpr
from flydsl.expr.typing import T
from flydsl.expr.typing import Vector as Vec

from primus_turbo.flydsl.utils.attn_helper_gfx1250 import (
    LOG2E,
    WAVE,
    buf_load,
    buf_load_b128,
    buf_store,
    cat,
    exp2,
    fmul,
    fsub,
    imax,
    imin,
    lds_load,
    lds_load_tr16,
    lds_store,
    make_rsrc,
    tensor_addr,
    to_bf16,
    uniform,
    vec_type,
    vmul_scalar,
    wmma_bf16,
    wmma_f16,
)


def _elem(dtype_str):
    if dtype_str == "bf16":
        return fx.BFloat16, wmma_bf16
    if dtype_str == "f16":
        return fx.Float16, wmma_f16
    raise ValueError(f"gfx1250 flash-attn backward supports bf16/f16, got {dtype_str}")


def _segment(varlen, CuQ, CuK, b, seq_q, seq_kv, sq_tok, skv_tok, bs_q, bs_kv):
    """(seqlen_q, seqlen_kv, q element base, kv element base, q token base) of batch ``b``."""
    if const_expr(varlen):
        rq = make_rsrc(tensor_addr(CuQ), 1 << 30)
        rk = make_rsrc(tensor_addr(CuK), 1 << 30)
        q_tok0 = uniform(fx.Int32(buf_load(rq, b * 4, T.i32)))
        seqlen_q = uniform(fx.Int32(buf_load(rq, b * 4 + 4, T.i32))) - q_tok0
        kv_tok0 = uniform(fx.Int32(buf_load(rk, b * 4, T.i32)))
        seqlen_kv = uniform(fx.Int32(buf_load(rk, b * 4 + 4, T.i32))) - kv_tok0
        return (
            seqlen_q,
            seqlen_kv,
            fx.Int64(q_tok0) * fx.Int64(sq_tok),
            fx.Int64(kv_tok0) * fx.Int64(skv_tok),
            q_tok0,
        )
    return seq_q, seq_kv, fx.Int64(b) * fx.Int64(bs_q), fx.Int64(b) * fx.Int64(bs_kv), b * seq_q


def _visible(q_pos, k_pos, seqlen_q, seqlen_kv, delta, causal, WL):
    ok = (k_pos < seqlen_kv) & (q_pos < seqlen_q)
    if const_expr(causal):
        ok = ok & (k_pos <= q_pos + delta)
    if const_expr(WL >= 0):
        ok = ok & (k_pos >= q_pos + delta - WL)
    return ok


@functools.lru_cache(maxsize=128)
def build_flash_attn_bwd_dkdv_gfx1250(
    num_heads_q,
    num_heads_kv,
    head_dim,
    causal=True,
    window_left=-1,
    varlen=False,
    softmax_scale=None,
    dtype_str="bf16",
    num_waves=4,
    kv_tiles=2,
    block_q=64,
):
    D = head_dim
    if D % 32 or not 32 <= D <= 256:
        raise ValueError(f"gfx1250 flash-attn backward needs head_dim % 32 == 0 and <= 256, got {D}")
    elem, mma = _elem(dtype_str)
    G = num_heads_q // num_heads_kv
    HKV = num_heads_kv
    KVT = kv_tiles
    BNK = num_waves * 16 * KVT
    BMQ = block_q
    QS = BMQ // 16
    QC = BMQ // 32
    KS = D // 32
    DT = D // 16
    BLOCK = num_waves * WAVE
    ROW = D * 2 + 16
    TILE_B = BMQ * ROW
    BUF_B = 2 * TILE_B  # Q tile then dO tile
    LDS_B = 2 * BUF_B
    CPR = D // 8
    if (BMQ * CPR) % BLOCK:
        raise ValueError("q tile does not split evenly over the workgroup")
    CH = BMQ * CPR // BLOCK
    WL = int(window_left)
    scale = (1.0 / math.sqrt(D)) if softmax_scale is None else float(softmax_scale)
    c_log2 = scale * LOG2E

    @flyc.kernel(known_block_size=[BLOCK, 1, 1])
    def flash_attn_bwd_dkdv_gfx1250_kernel(
        Q: fx.Tensor,
        K: fx.Tensor,
        V: fx.Tensor,
        DO: fx.Tensor,
        DK: fx.Tensor,
        DV: fx.Tensor,
        LSE2: fx.Tensor,
        DELTA: fx.Tensor,
        CuQ: fx.Tensor,
        CuK: fx.Tensor,
        seq_q: fx.Int32,
        seq_kv: fx.Int32,
        sq_tok: fx.Int32,
        skv_tok: fx.Int32,
        bs_q: fx.Int32,
        bs_kv: fx.Int32,
        n_tok: fx.Int32,
    ):
        tid = fx.Int32(fx.thread_idx.x)
        wave = uniform(tid // WAVE)
        lane = tid % WAVE
        l16 = lane % 16
        hi = lane // 16
        l8 = lane % 8
        kb = fx.Int32(fx.block_idx.x)
        hk = fx.Int32(fx.block_idx.y)
        b = fx.Int32(fx.block_idx.z)
        seqlen_q, seqlen_kv, q_base, kv_base, q_tok0 = _segment(
            varlen, CuQ, CuK, b, seq_q, seq_kv, sq_tok, skv_tok, bs_q, bs_kv
        )
        delta = seqlen_kv - seqlen_q
        k0 = kb * BNK
        wk0 = k0 + wave * (16 * KVT)

        # q range that can see keys [k0, k0 + BNK).
        if const_expr(causal):
            q_lo = imax(k0 - delta, 0)
        else:
            q_lo = fx.Int32(0)
        if const_expr(WL >= 0):
            q_hi = imin(seqlen_q, k0 + BNK + WL - delta)
        else:
            q_hi = seqlen_q
        q_hi = fx.Int32((k0 < seqlen_kv).select(q_hi, fx.Int32(0)))
        t_lo = q_lo // BMQ
        t_hi = imax((q_hi + (BMQ - 1)) // BMQ, t_lo)
        nt = t_hi - t_lo
        n_iter = nt * G

        arena = fx.SharedAllocator(static=False)
        arena.allocate(LDS_B)
        lds0 = fx.Int32(fx.Int64(fx.ptrtoint(arena.base_ptr)))

        # ---- K^T / V^T B fragments for this wave's keys, resident.
        kv_rows_valid = imax(imin(seqlen_kv - k0, BNK), 0)
        kv_off = (kv_base + fx.Int64(k0) * fx.Int64(skv_tok) + fx.Int64(hk * D)) * 2
        rsrc_k = make_rsrc(tensor_addr(K) + kv_off, kv_rows_valid * skv_tok * 2)
        rsrc_v = make_rsrc(tensor_addr(V) + kv_off, kv_rows_valid * skv_tok * 2)
        kt_frag, vt_frag = [], []
        for kvs in range_constexpr(KVT):
            row_off = (wave * (16 * KVT) + kvs * 16 + l16) * skv_tok * 2 + hi * 16
            kf, vf = [], []
            for ks in range_constexpr(KS):
                kf.append(
                    cat(
                        buf_load_b128(rsrc_k, row_off + ks * 64, elem),
                        buf_load_b128(rsrc_k, row_off + ks * 64 + 32, elem),
                    )
                )
                vf.append(
                    cat(
                        buf_load_b128(rsrc_v, row_off + ks * 64, elem),
                        buf_load_b128(rsrc_v, row_off + ks * 64 + 32, elem),
                    )
                )
            kt_frag.append(kf)
            vt_frag.append(vf)

        g_off, l_off = [], []
        for c in range_constexpr(CH):
            idx = tid + c * BLOCK
            g_off.append((idx // CPR) * sq_tok * 2 + (idx % CPR) * 16)
            l_off.append((idx // CPR) * ROW + (idx % CPR) * 16)
        q_addr0 = tensor_addr(Q) + q_base * 2
        do_addr0 = tensor_addr(DO) + q_base * 2
        lse_addr0 = tensor_addr(LSE2)
        dl_addr0 = tensor_addr(DELTA)
        v4i = vec_type(4, fx.Int32)
        v4f = vec_type(4, fx.Float32)

        def decode(i):
            g = i // imax(nt, 1)
            return hk * G + g, t_lo + (i - g * nt)

        def load_tile(i):
            h, t = decode(i)
            start = t * BMQ
            # Past the last iteration decode() names a head outside the group; read nothing.
            rows = fx.Int32((i < n_iter).select(imax(imin(seqlen_q - start, BMQ), 0), fx.Int32(0)))
            off = (fx.Int64(start) * fx.Int64(sq_tok) + fx.Int64(h * D)) * 2
            rq_ = make_rsrc(q_addr0 + off, rows * sq_tok * 2)
            rd_ = make_rsrc(do_addr0 + off, rows * sq_tok * 2)
            qs_ = [buf_load(rq_, g_off[c], v4i) for c in range_constexpr(CH)]
            ds_ = [buf_load(rd_, g_off[c], v4i) for c in range_constexpr(CH)]
            # A 128-bit buffer load straddling num_records returns all zeros, so round the
            # bound up to whole vec4s; the host pads every row with >= 4 zero columns.
            soff = (fx.Int64(h) * fx.Int64(n_tok) + fx.Int64(q_tok0 + start)) * 4
            rows4 = (rows + 3) // 4 * 16
            rl_ = make_rsrc(lse_addr0 + soff, rows4)
            rdl_ = make_rsrc(dl_addr0 + soff, rows4)
            ls_, dl_ = [], []
            for qs in range_constexpr(QS):
                o = (qs * 16 + hi * 8) * 4
                ls_.append(cat(buf_load(rl_, o, v4f), buf_load(rl_, o + 16, v4f)))
                dl_.append(cat(buf_load(rdl_, o, v4f), buf_load(rdl_, o + 16, v4f)))
            return qs_, ds_, ls_, dl_

        def store_tile(regs, buf):
            qs_, ds_ = regs[0], regs[1]
            base = lds0 + buf * BUF_B
            for c in range_constexpr(CH):
                lds_store(qs_[c], base + l_off[c])
                lds_store(ds_[c], base + TILE_B + l_off[c])

        a_lane = l16 * ROW + hi * 16
        tr_lane = (hi * 8 + l8) * ROW + (l16 // 8) * 16
        v8e = vec_type(8, elem)
        k_pos = [wk0 + kvs * 16 + l16 for kvs in range_constexpr(KVT)]

        def tile_compute(i, buf, stats, dk_acc, dv_acc):
            _, t = decode(i)
            ls_, dl_ = stats
            qbase = lds0 + buf * BUF_B
            dobase = qbase + TILE_B
            s = [[Vec.filled(8, 0.0, fx.Float32) for _ in range_constexpr(KVT)] for _ in range_constexpr(QS)]
            dp = [[Vec.filled(8, 0.0, fx.Float32) for _ in range_constexpr(KVT)] for _ in range_constexpr(QS)]
            for qs in range_constexpr(QS):
                for ks in range_constexpr(KS):
                    o = qs * 16 * ROW + ks * 64
                    aq = cat(lds_load(qbase + a_lane + o, v8e), lds_load(qbase + a_lane + o + 32, v8e))
                    ad = cat(lds_load(dobase + a_lane + o, v8e), lds_load(dobase + a_lane + o + 32, v8e))
                    for kvs in range_constexpr(KVT):
                        s[qs][kvs] = mma(aq, kt_frag[kvs][ks], s[qs][kvs])
                        dp[qs][kvs] = mma(ad, vt_frag[kvs][ks], dp[qs][kvs])
            # P = exp2(S*c - lse2); dS = P * (dP - delta). Lane = key, element i = q row.
            p_pk = [[None] * KVT for _ in range_constexpr(QS)]
            ds_pk = [[None] * KVT for _ in range_constexpr(QS)]
            q_row0 = t * BMQ + hi * 8
            for qs in range_constexpr(QS):
                lsv = Vec(ls_[qs])
                dlv = Vec(dl_[qs])
                for kvs in range_constexpr(KVT):
                    sv = vmul_scalar(s[qs][kvs], c_log2)
                    pv, dsv = [], []
                    for e in range_constexpr(8):
                        ok = _visible(
                            q_row0 + (qs * 16 + e), k_pos[kvs], seqlen_q, seqlen_kv, delta, causal, WL
                        )
                        p = fx.Float32(ok.select(exp2(fsub(sv[e], lsv[e])), fx.Float32(0.0)))
                        pv.append(p)
                        dsv.append(fmul(p, fsub(dp[qs][kvs][e], dlv[e])))
                    p_pk[qs][kvs] = to_bf16(Vec.from_elements(pv, fx.Float32), elem)
                    ds_pk[qs][kvs] = to_bf16(Vec.from_elements(dsv, fx.Float32), elem)
            dk_new = [list(r) for r in dk_acc]
            dv_new = [list(r) for r in dv_acc]
            for dt in range_constexpr(DT):
                for qc in range_constexpr(QC):
                    o = qc * 32 * ROW + dt * 32
                    a_do = cat(
                        lds_load_tr16(dobase + tr_lane + o, elem),
                        lds_load_tr16(dobase + tr_lane + o + 16 * ROW, elem),
                    )
                    a_q = cat(
                        lds_load_tr16(qbase + tr_lane + o, elem),
                        lds_load_tr16(qbase + tr_lane + o + 16 * ROW, elem),
                    )
                    for kvs in range_constexpr(KVT):
                        bp = cat(p_pk[2 * qc][kvs], p_pk[2 * qc + 1][kvs])
                        bds = cat(ds_pk[2 * qc][kvs], ds_pk[2 * qc + 1][kvs])
                        dv_new[dt][kvs] = mma(a_do, bp, dv_new[dt][kvs])
                        dk_new[dt][kvs] = mma(a_q, bds, dk_new[dt][kvs])
            return dk_new, dv_new

        first = load_tile(fx.Int32(0))
        store_tile(first, fx.Int32(0))
        gpu.barrier()

        init = list(first[2]) + list(first[3])
        for _ in range_constexpr(2 * DT * KVT):
            init.append(Vec.filled(8, 0.0, fx.Float32))
        NS = 2 * QS
        for it, st in range(fx.Index(0), fx.Index(n_iter), fx.Index(1), init=init):
            i = fx.Int32(it)
            stats = ([st[qs] for qs in range_constexpr(QS)], [st[QS + qs] for qs in range_constexpr(QS)])
            dk_acc = [[st[NS + dt * KVT + kvs] for kvs in range_constexpr(KVT)] for dt in range_constexpr(DT)]
            dv_acc = [
                [st[NS + DT * KVT + dt * KVT + kvs] for kvs in range_constexpr(KVT)]
                for dt in range_constexpr(DT)
            ]
            buf = i % 2
            nxt = load_tile(i + 1)
            dk_acc, dv_acc = tile_compute(i, buf, stats, dk_acc, dv_acc)
            store_tile(nxt, 1 - buf)
            gpu.barrier()
            out = list(nxt[2]) + list(nxt[3])
            for dt in range_constexpr(DT):
                out += dk_acc[dt]
            for dt in range_constexpr(DT):
                out += dv_acc[dt]
            res = yield out

        rsrc_dk = make_rsrc(tensor_addr(DK) + kv_off, kv_rows_valid * skv_tok * 2)
        rsrc_dv = make_rsrc(tensor_addr(DV) + kv_off, kv_rows_valid * skv_tok * 2)
        for kvs in range_constexpr(KVT):
            row_off = (wave * (16 * KVT) + kvs * 16 + l16) * skv_tok * 2 + hi * 16
            for dt in range_constexpr(DT):
                dk = vmul_scalar(res[NS + dt * KVT + kvs], scale)
                dv = res[NS + DT * KVT + dt * KVT + kvs]
                buf_store(to_bf16(dk, elem).bitcast(fx.Int32), rsrc_dk, row_off + dt * 32)
                buf_store(to_bf16(dv, elem).bitcast(fx.Int32), rsrc_dv, row_off + dt * 32)

    @flyc.jit
    def launch_dkdv(
        Q: fx.Tensor,
        K: fx.Tensor,
        V: fx.Tensor,
        DO: fx.Tensor,
        DK: fx.Tensor,
        DV: fx.Tensor,
        LSE2: fx.Tensor,
        DELTA: fx.Tensor,
        CuQ: fx.Tensor,
        CuK: fx.Tensor,
        batch: fx.Int32,
        seq_q: fx.Int32,
        seq_kv: fx.Int32,
        sq_tok: fx.Int32,
        skv_tok: fx.Int32,
        bs_q: fx.Int32,
        bs_kv: fx.Int32,
        n_tok: fx.Int32,
        stream: fx.Stream = fx.Stream(None),  # noqa: B008
    ):
        nkb = (fx.Index(seq_kv) + BNK - 1) // BNK
        flash_attn_bwd_dkdv_gfx1250_kernel(
            Q, K, V, DO, DK, DV, LSE2, DELTA, CuQ, CuK, seq_q, seq_kv, sq_tok, skv_tok, bs_q, bs_kv, n_tok
        ).launch(grid=(nkb, HKV, fx.Index(batch)), block=(BLOCK, 1, 1), stream=stream)

    return _cached_launcher(launch_dkdv)


@functools.lru_cache(maxsize=128)
def build_flash_attn_bwd_dq_gfx1250(
    num_heads_q,
    num_heads_kv,
    head_dim,
    causal=True,
    window_left=-1,
    varlen=False,
    softmax_scale=None,
    dtype_str="bf16",
    num_waves=4,
    q_tiles=2,
    block_n=64,
):
    D = head_dim
    if D % 32 or not 32 <= D <= 256:
        raise ValueError(f"gfx1250 flash-attn backward needs head_dim % 32 == 0 and <= 256, got {D}")
    elem, mma = _elem(dtype_str)
    G = num_heads_q // num_heads_kv
    HQ = num_heads_q
    QT = q_tiles
    BM = num_waves * 16 * QT
    BN = block_n
    KT = BN // 16
    PC = BN // 32
    KS = D // 32
    DT = D // 16
    BLOCK = num_waves * WAVE
    ROW = D * 2 + 16
    TILE_B = BN * ROW
    BUF_B = 2 * TILE_B  # K tile then V tile
    LDS_B = 2 * BUF_B
    CPR = D // 8
    if (BN * CPR) % BLOCK:
        raise ValueError("KV tile does not split evenly over the workgroup")
    CH = BN * CPR // BLOCK
    WL = int(window_left)
    scale = (1.0 / math.sqrt(D)) if softmax_scale is None else float(softmax_scale)
    c_log2 = scale * LOG2E

    @flyc.kernel(known_block_size=[BLOCK, 1, 1])
    def flash_attn_bwd_dq_gfx1250_kernel(
        Q: fx.Tensor,
        K: fx.Tensor,
        V: fx.Tensor,
        DO: fx.Tensor,
        DQ: fx.Tensor,
        LSE2: fx.Tensor,
        DELTA: fx.Tensor,
        CuQ: fx.Tensor,
        CuK: fx.Tensor,
        seq_q: fx.Int32,
        seq_kv: fx.Int32,
        sq_tok: fx.Int32,
        skv_tok: fx.Int32,
        bs_q: fx.Int32,
        bs_kv: fx.Int32,
        n_tok: fx.Int32,
    ):
        tid = fx.Int32(fx.thread_idx.x)
        wave = uniform(tid // WAVE)
        lane = tid % WAVE
        l16 = lane % 16
        hi = lane // 16
        l8 = lane % 8
        bx = fx.Int32(fx.block_idx.x)
        if const_expr(causal):
            qb = (seq_q + (BM - 1)) // BM - 1 - bx
        else:
            qb = bx
        h = fx.Int32(fx.block_idx.y)
        b = fx.Int32(fx.block_idx.z)
        hk = h // G
        seqlen_q, seqlen_kv, q_base, kv_base, q_tok0 = _segment(
            varlen, CuQ, CuK, b, seq_q, seq_kv, sq_tok, skv_tok, bs_q, bs_kv
        )
        q0 = qb * BM
        delta = seqlen_kv - seqlen_q
        if const_expr(causal):
            kv_hi = imax(imin(seqlen_kv, q0 + BM + delta), 0)
        else:
            kv_hi = seqlen_kv
        kv_hi = fx.Int32((q0 < seqlen_q).select(kv_hi, fx.Int32(0)))
        t_hi = (kv_hi + (BN - 1)) // BN
        if const_expr(WL >= 0):
            t_lo = imin(imax(q0 + delta - WL, 0) // BN, t_hi)
        else:
            t_lo = fx.Int32(0)

        arena = fx.SharedAllocator(static=False)
        arena.allocate(LDS_B)
        lds0 = fx.Int32(fx.Int64(fx.ptrtoint(arena.base_ptr)))

        q_rows_valid = imax(imin(seqlen_q - q0, BM), 0)
        q_off = (q_base + fx.Int64(q0) * fx.Int64(sq_tok) + fx.Int64(h * D)) * 2
        rsrc_q = make_rsrc(tensor_addr(Q) + q_off, q_rows_valid * sq_tok * 2)
        rsrc_do = make_rsrc(tensor_addr(DO) + q_off, q_rows_valid * sq_tok * 2)
        wrow0 = wave * (16 * QT)
        q_frag, do_frag = [], []
        for qt in range_constexpr(QT):
            row_off = (wrow0 + qt * 16 + l16) * sq_tok * 2 + hi * 16
            qf, df = [], []
            for ks in range_constexpr(KS):
                qf.append(
                    cat(
                        buf_load_b128(rsrc_q, row_off + ks * 64, elem),
                        buf_load_b128(rsrc_q, row_off + ks * 64 + 32, elem),
                    )
                )
                df.append(
                    cat(
                        buf_load_b128(rsrc_do, row_off + ks * 64, elem),
                        buf_load_b128(rsrc_do, row_off + ks * 64 + 32, elem),
                    )
                )
            q_frag.append(qf)
            do_frag.append(df)
        # Per-lane row statistics: lane owns query column l16 of each q tile.
        soff = (fx.Int64(h) * fx.Int64(n_tok) + fx.Int64(q_tok0 + q0)) * 4
        rsrc_l = make_rsrc(tensor_addr(LSE2) + soff, q_rows_valid * 4)
        rsrc_dl = make_rsrc(tensor_addr(DELTA) + soff, q_rows_valid * 4)
        lse2 = [
            fx.Float32(buf_load(rsrc_l, (wrow0 + qt * 16 + l16) * 4, T.f32)) for qt in range_constexpr(QT)
        ]
        dlt = [
            fx.Float32(buf_load(rsrc_dl, (wrow0 + qt * 16 + l16) * 4, T.f32)) for qt in range_constexpr(QT)
        ]

        k_addr0 = tensor_addr(K) + (kv_base + fx.Int64(hk * D)) * 2
        v_addr0 = tensor_addr(V) + (kv_base + fx.Int64(hk * D)) * 2
        g_off, l_off = [], []
        for c in range_constexpr(CH):
            idx = tid + c * BLOCK
            g_off.append((idx // CPR) * skv_tok * 2 + (idx % CPR) * 16)
            l_off.append((idx // CPR) * ROW + (idx % CPR) * 16)
        v4i = vec_type(4, fx.Int32)

        def load_kv(t):
            start = t * BN
            rows = imax(imin(seqlen_kv - start, BN), 0)
            off = fx.Int64(start) * fx.Int64(skv_tok) * 2
            rk_ = make_rsrc(k_addr0 + off, rows * skv_tok * 2)
            rv_ = make_rsrc(v_addr0 + off, rows * skv_tok * 2)
            return [buf_load(rk_, g_off[c], v4i) for c in range_constexpr(CH)], [
                buf_load(rv_, g_off[c], v4i) for c in range_constexpr(CH)
            ]

        def store_kv(regs, buf):
            base = lds0 + buf * BUF_B
            for c in range_constexpr(CH):
                lds_store(regs[0][c], base + l_off[c])
                lds_store(regs[1][c], base + TILE_B + l_off[c])

        a_lane = l16 * ROW + hi * 16
        tr_lane = (hi * 8 + l8) * ROW + (l16 // 8) * 16
        v8e = vec_type(8, elem)
        q_pos = [q0 + wrow0 + qt * 16 + l16 for qt in range_constexpr(QT)]

        def tile_compute(t, buf, dq_acc):
            kbase = lds0 + buf * BUF_B
            vbase = kbase + TILE_B
            s = [[Vec.filled(8, 0.0, fx.Float32) for _ in range_constexpr(KT)] for _ in range_constexpr(QT)]
            dp = [[Vec.filled(8, 0.0, fx.Float32) for _ in range_constexpr(KT)] for _ in range_constexpr(QT)]
            for kt in range_constexpr(KT):
                for ks in range_constexpr(KS):
                    o = kt * 16 * ROW + ks * 64
                    ak = cat(lds_load(kbase + a_lane + o, v8e), lds_load(kbase + a_lane + o + 32, v8e))
                    av = cat(lds_load(vbase + a_lane + o, v8e), lds_load(vbase + a_lane + o + 32, v8e))
                    for qt in range_constexpr(QT):
                        s[qt][kt] = mma(ak, q_frag[qt][ks], s[qt][kt])
                        dp[qt][kt] = mma(av, do_frag[qt][ks], dp[qt][kt])
            kv0 = t * BN + hi * 8
            ds_frag = []
            for qt in range_constexpr(QT):
                packs = []
                for kt in range_constexpr(KT):
                    sv = vmul_scalar(s[qt][kt], c_log2)
                    dsv = []
                    for e in range_constexpr(8):
                        ok = _visible(q_pos[qt], kv0 + (kt * 16 + e), seqlen_q, seqlen_kv, delta, causal, WL)
                        p = fx.Float32(ok.select(exp2(fsub(sv[e], lse2[qt])), fx.Float32(0.0)))
                        dsv.append(fmul(p, fsub(dp[qt][kt][e], dlt[qt])))
                    packs.append(to_bf16(Vec.from_elements(dsv, fx.Float32), elem))
                ds_frag.append([cat(packs[2 * pc], packs[2 * pc + 1]) for pc in range_constexpr(PC)])
            new = [list(r) for r in dq_acc]
            for dt in range_constexpr(DT):
                for pc in range_constexpr(PC):
                    base = kbase + tr_lane + (pc * 32 * ROW + dt * 32)
                    a = cat(lds_load_tr16(base, elem), lds_load_tr16(base + 16 * ROW, elem))
                    for qt in range_constexpr(QT):
                        new[qt][dt] = mma(a, ds_frag[qt][pc], new[qt][dt])
            return new

        store_kv(load_kv(t_lo), fx.Int32(0))
        gpu.barrier()
        init = [Vec.filled(8, 0.0, fx.Float32) for _ in range_constexpr(QT * DT)]
        for t, st in range(fx.Index(t_lo), fx.Index(t_hi), fx.Index(1), init=init):
            ti = fx.Int32(t)
            acc = [[st[qt * DT + dt] for dt in range_constexpr(DT)] for qt in range_constexpr(QT)]
            buf = (ti - t_lo) % 2
            nxt = load_kv(ti + 1)
            acc = tile_compute(ti, buf, acc)
            store_kv(nxt, 1 - buf)
            gpu.barrier()
            out = []
            for qt in range_constexpr(QT):
                out += acc[qt]
            res = yield out

        rsrc_dq = make_rsrc(tensor_addr(DQ) + q_off, q_rows_valid * sq_tok * 2)
        for qt in range_constexpr(QT):
            row_off = (wrow0 + qt * 16 + l16) * sq_tok * 2 + hi * 16
            for dt in range_constexpr(DT):
                dq = vmul_scalar(res[qt * DT + dt], scale)
                buf_store(to_bf16(dq, elem).bitcast(fx.Int32), rsrc_dq, row_off + dt * 32)

    @flyc.jit
    def launch_dq(
        Q: fx.Tensor,
        K: fx.Tensor,
        V: fx.Tensor,
        DO: fx.Tensor,
        DQ: fx.Tensor,
        LSE2: fx.Tensor,
        DELTA: fx.Tensor,
        CuQ: fx.Tensor,
        CuK: fx.Tensor,
        batch: fx.Int32,
        seq_q: fx.Int32,
        seq_kv: fx.Int32,
        sq_tok: fx.Int32,
        skv_tok: fx.Int32,
        bs_q: fx.Int32,
        bs_kv: fx.Int32,
        n_tok: fx.Int32,
        stream: fx.Stream = fx.Stream(None),  # noqa: B008
    ):
        nqb = (fx.Index(seq_q) + BM - 1) // BM
        flash_attn_bwd_dq_gfx1250_kernel(
            Q, K, V, DO, DQ, LSE2, DELTA, CuQ, CuK, seq_q, seq_kv, sq_tok, skv_tok, bs_q, bs_kv, n_tok
        ).launch(grid=(nqb, HQ, fx.Index(batch)), block=(BLOCK, 1, 1), stream=stream)

    return _cached_launcher(launch_dq)


def _cached_launcher(jit_fn):
    compiled = {}

    def run(*args, stream=None):
        fn = compiled.get("fn")
        if fn is None:
            fn = flyc.compile(jit_fn, *args, fx.Stream(stream))
            compiled["fn"] = fn
        return fn(*args, stream)

    return run


def _pad_rows16(x):
    """[H, T] fp32 view with a 16-byte-multiple row pitch and >= 4 finite pad columns: the
    dK/dV kernel reads the statistics with 128-bit loads whose bounds are rounded up to 4.
    Views from ``attn_bwd_prep`` already have that shape and pass through."""
    t = x.shape[1]
    if x.dtype == torch.float32 and x.stride(1) == 1 and x.stride(0) % 4 == 0 and x.stride(0) >= t + 4:
        return x
    out = torch.zeros(x.shape[0], (t + 3) // 4 * 4 + 4, device=x.device, dtype=torch.float32)
    out[:, :t].copy_(x)
    return out[:, :t]


def flash_attn_bwd_gfx1250(
    dout,
    q,
    k,
    v,
    lse2_hm,
    delta_hm,
    batch,
    seq_q,
    seq_kv,
    sq_tok,
    skv_tok,
    bs_q=0,
    bs_kv=0,
    *,
    num_heads_q,
    num_heads_kv,
    head_dim,
    causal=True,
    window_left=-1,
    softmax_scale=None,
    cu_seqlens_q=None,
    cu_seqlens_kv=None,
    stream=None,
):
    """dQ, dK, dV for the layouts described in ``flash_attn_fwd_gfx1250._launch``.

    ``dout`` must share q's layout. ``lse2_hm`` / ``delta_hm`` are ``[Hq, tokens]`` fp32:
    natural LSE times log2(e) (``+inf`` where no key is visible) and ``rowsum(dO * O)``.
    """
    varlen = cu_seqlens_q is not None
    dtype_str = "bf16" if q.dtype == torch.bfloat16 else "f16"
    dq = torch.empty_like(q)
    dk = torch.empty_like(k)
    dv = torch.empty_like(v)
    cu_q = q if cu_seqlens_q is None else cu_seqlens_q
    cu_k = q if cu_seqlens_kv is None else cu_seqlens_kv
    lse2_hm, delta_hm = _pad_rows16(lse2_hm), _pad_rows16(delta_hm)
    n_tok = lse2_hm.stride(0)
    common = (
        int(batch),
        int(seq_q),
        int(seq_kv),
        int(sq_tok),
        int(skv_tok),
        int(bs_q),
        int(bs_kv),
        int(n_tok),
    )
    key = (
        num_heads_q,
        num_heads_kv,
        head_dim,
        bool(causal),
        int(window_left),
        varlen,
        softmax_scale,
        dtype_str,
    )
    dkdv = build_flash_attn_bwd_dkdv_gfx1250(*key)
    dkdv(q, k, v, dout, dk, dv, lse2_hm, delta_hm, cu_q, cu_k, *common, stream=stream)
    dqk = build_flash_attn_bwd_dq_gfx1250(*key)
    dqk(q, k, v, dout, dq, lse2_hm, delta_hm, cu_q, cu_k, *common, stream=stream)
    return dq, dk, dv
