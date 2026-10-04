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

"""Flash-attention forward for gfx1250 (MI455X): wave32, v_wmma_f32_16x16x32_bf16.

The gfx950 dual-wave kernel (``flash_attn_fwd.py``) is MFMA/wave64 throughout, so this is a
separate kernel rather than a retarget. It covers the same surface: bottom-right causal, a
left sliding window, GQA, a learned per-head sink, LSE emission, and both packed varlen (THD,
ragged segments from cu_seqlens) and strided dense (SBHD / BSHD) layouts.

Each wave owns ``16 * Q_TILES`` query rows and computes the transposed problem,
``S^T = K Q^T`` and ``O^T += V^T P^T``. In that orientation a lane holds one query column of
every score tile, so the row max, the rescale, and the row sum are in-lane (one lane swap per
tile for the max), and the score accumulators are already the B operand of the P*V WMMA (see
``attn_helper_gfx1250``). K and V stream through a double-buffered LDS tile; V^T fragments
come from ``ds_load_tr16_b128``.
"""

import functools
import math

import flydsl.compiler as flyc
import flydsl.expr as fx
from flydsl.expr import const_expr, gpu, range_constexpr
from flydsl.expr.typing import T
from flydsl.expr.typing import Vector as Vec

from primus_turbo.flydsl.utils.attn_helper_gfx1250 import (
    LN2,
    LOG2E,
    WAVE,
    buf_load,
    buf_load_b128,
    buf_store,
    cat,
    exp2,
    fadd,
    fmax,
    fmul,
    fsub,
    imax,
    imin,
    lds_load,
    lds_load_tr16,
    lds_store,
    log2,
    make_rsrc,
    rcp,
    swap_halves,
    tensor_addr,
    to_bf16,
    uniform,
    vec_type,
    vmul_scalar,
    wmma_bf16,
    wmma_f16,
)

_NEG_INF = float("-inf")


@functools.lru_cache(maxsize=128)
def build_flash_attn_fwd_gfx1250(
    num_heads_q,
    num_heads_kv,
    head_dim,
    causal=True,
    window_left=-1,
    has_sink=False,
    emit_lse=True,
    varlen=False,
    softmax_scale=None,
    dtype_str="bf16",
    num_waves=4,
    q_tiles=2,
    block_n=64,
):
    """Build the gfx1250 forward launcher; see ``_launch`` for the runtime arguments."""
    D = head_dim
    if D % 32 or not 32 <= D <= 256:
        raise ValueError(f"gfx1250 flash-attn forward needs head_dim % 32 == 0 and <= 256, got {D}")
    if num_heads_q % num_heads_kv:
        raise ValueError(f"num_heads_q ({num_heads_q}) must be a multiple of num_heads_kv ({num_heads_kv})")
    if dtype_str not in ("bf16", "f16"):
        raise ValueError(f"gfx1250 flash-attn forward supports bf16/f16, got {dtype_str}")
    elem = fx.BFloat16 if dtype_str == "bf16" else fx.Float16
    mma = wmma_bf16 if dtype_str == "bf16" else wmma_f16
    G = num_heads_q // num_heads_kv
    HQ = num_heads_q
    QT = q_tiles
    BM = num_waves * 16 * QT
    BN = block_n
    KT = BN // 16  # 16-row kv sub-tiles per KV tile
    PC = BN // 32  # 32-row kv chunks (P*V reduction steps)
    KS = D // 32  # QK reduction steps
    DT = D // 16  # 16-column d tiles of O^T
    BLOCK = num_waves * WAVE
    ROW = D * 2 + 16  # LDS row pitch, bytes; a multiple of 16 for ds_load_tr16_b128
    TILE_B = BN * ROW
    BUF_B = 2 * TILE_B  # K tile then V tile
    LDS_B = 2 * BUF_B
    CPR = D // 8  # 16-byte chunks per row
    if (BN * CPR) % BLOCK:
        raise ValueError("KV tile does not split evenly over the workgroup")
    CH = BN * CPR // BLOCK
    WL = int(window_left)
    scale = (1.0 / math.sqrt(D)) if softmax_scale is None else float(softmax_scale)
    c_log2 = scale * LOG2E

    @flyc.kernel(known_block_size=[BLOCK, 1, 1])
    def flash_attn_fwd_gfx1250_kernel(
        Q: fx.Tensor,
        K: fx.Tensor,
        V: fx.Tensor,
        O: fx.Tensor,  # noqa: E741
        LSE: fx.Tensor,
        CuQ: fx.Tensor,
        CuK: fx.Tensor,
        SINK: fx.Tensor,
        seq_q: fx.Int32,
        seq_kv: fx.Int32,
        sq_tok: fx.Int32,
        skv_tok: fx.Int32,
        bs_q: fx.Int32,
        bs_kv: fx.Int32,
    ):
        tid = fx.Int32(fx.thread_idx.x)
        wave = uniform(tid // WAVE)
        lane = tid % WAVE
        l16 = lane % 16
        hi = lane // 16
        l8 = lane % 8

        bx = fx.Int32(fx.block_idx.x)
        if const_expr(causal):
            # Causal work grows with the q block, so dispatch the longest blocks first.
            qb = (seq_q + (BM - 1)) // BM - 1 - bx
        else:
            qb = bx
        h = fx.Int32(fx.block_idx.y)
        b = fx.Int32(fx.block_idx.z)
        hk = h // G

        if const_expr(varlen):
            rq = make_rsrc(tensor_addr(CuQ), 1 << 30)
            rk = make_rsrc(tensor_addr(CuK), 1 << 30)
            q_tok0 = uniform(fx.Int32(buf_load(rq, b * 4, T.i32)))
            seqlen_q = uniform(fx.Int32(buf_load(rq, b * 4 + 4, T.i32))) - q_tok0
            kv_tok0 = uniform(fx.Int32(buf_load(rk, b * 4, T.i32)))
            seqlen_kv = uniform(fx.Int32(buf_load(rk, b * 4 + 4, T.i32))) - kv_tok0
            q_base = fx.Int64(q_tok0) * fx.Int64(sq_tok)
            kv_base = fx.Int64(kv_tok0) * fx.Int64(skv_tok)
            lse_tok0 = q_tok0
        else:
            seqlen_q = seq_q
            seqlen_kv = seq_kv
            q_base = fx.Int64(b) * fx.Int64(bs_q)
            kv_base = fx.Int64(b) * fx.Int64(bs_kv)
            lse_tok0 = b * seq_q

        q0 = qb * BM
        delta = seqlen_kv - seqlen_q  # bottom-right alignment offset

        # KV tile range touched by this q block. An inactive block (q0 past the segment)
        # gets an empty range and fully masked stores, so there is no early-exit branch.
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

        # ---- Q fragments (B operand of S^T = K Q^T), resident for the whole block.
        q_rows_valid = imax(imin(seqlen_q - q0, BM), 0)
        q_addr = tensor_addr(Q) + (q_base + fx.Int64(q0) * fx.Int64(sq_tok) + fx.Int64(h * D)) * 2
        rsrc_q = make_rsrc(q_addr, q_rows_valid * sq_tok * 2)
        wrow0 = wave * (16 * QT)
        q_frag = []
        for qt in range_constexpr(QT):
            row_off = (wrow0 + qt * 16 + l16) * sq_tok * 2 + hi * 16
            frs = []
            for ks in range_constexpr(KS):
                lo = buf_load_b128(rsrc_q, row_off + ks * 64, elem)
                hi_ = buf_load_b128(rsrc_q, row_off + ks * 64 + 32, elem)
                frs.append(cat(lo, hi_))
            q_frag.append(frs)

        # ---- KV tile staging: each thread moves CH 16-byte chunks of K and of V.
        k_addr0 = tensor_addr(K) + (kv_base + fx.Int64(hk * D)) * 2
        v_addr0 = tensor_addr(V) + (kv_base + fx.Int64(hk * D)) * 2
        g_off = []
        l_off = []
        for c in range_constexpr(CH):
            idx = tid + c * BLOCK
            row = idx // CPR
            col = idx % CPR
            g_off.append(row * skv_tok * 2 + col * 16)
            l_off.append(row * ROW + col * 16)

        def load_kv(t):
            start = t * BN
            rows = imax(imin(seqlen_kv - start, BN), 0)
            off = fx.Int64(start) * fx.Int64(skv_tok) * 2
            nbytes = rows * skv_tok * 2
            rk_ = make_rsrc(k_addr0 + off, nbytes)
            rv_ = make_rsrc(v_addr0 + off, nbytes)
            ks_ = [buf_load(rk_, g_off[c], vec_type(4, fx.Int32)) for c in range_constexpr(CH)]
            vs_ = [buf_load(rv_, g_off[c], vec_type(4, fx.Int32)) for c in range_constexpr(CH)]
            return ks_, vs_

        def store_kv(regs, buf):
            ks_, vs_ = regs
            base = lds0 + buf * BUF_B
            for c in range_constexpr(CH):
                lds_store(ks_[c], base + l_off[c])
                lds_store(vs_[c], base + TILE_B + l_off[c])

        # Per-lane LDS read bases; every fragment is one of these plus a constant.
        k_lane = l16 * ROW + hi * 16
        v_lane = (hi * 8 + l8) * ROW + (l16 // 8) * 16
        v8e = vec_type(8, elem)

        # Global row positions this lane's query columns map to.
        q_pos = [q0 + wrow0 + qt * 16 + l16 for qt in range_constexpr(QT)]

        def tile_compute(t, buf, m_run, l_run, o_acc):
            kbase = lds0 + buf * BUF_B
            vbase = kbase + TILE_B
            # S^T tiles: s[qt][kt] holds kv rows kt*16 + hi*8 + i of query column l16.
            s = [[Vec.filled(8, 0.0, fx.Float32) for _ in range_constexpr(KT)] for _ in range_constexpr(QT)]
            for kt in range_constexpr(KT):
                for ks in range_constexpr(KS):
                    a_lo = lds_load(kbase + k_lane + (kt * 16 * ROW + ks * 64), v8e)
                    a_hi = lds_load(kbase + k_lane + (kt * 16 * ROW + ks * 64 + 32), v8e)
                    a = cat(a_lo, a_hi)
                    for qt in range_constexpr(QT):
                        s[qt][kt] = mma(a, q_frag[qt][ks], s[qt][kt])

            kv0 = t * BN + hi * 8
            p_frag = []
            new_m, new_l, alpha = [], [], []
            for qt in range_constexpr(QT):
                vals = []
                for kt in range_constexpr(KT):
                    sv = vmul_scalar(s[qt][kt], c_log2)
                    for i in range_constexpr(8):
                        kj = kv0 + (kt * 16 + i)
                        ok = kj < seqlen_kv
                        if const_expr(causal):
                            ok = ok & (kj <= q_pos[qt] + delta)
                        if const_expr(WL >= 0):
                            ok = ok & (kj >= q_pos[qt] + delta - WL)
                        vals.append(fx.Float32(ok.select(sv[i], fx.Float32(_NEG_INF))))
                tmax = vals[0]
                for v in vals[1:]:
                    tmax = fmax(tmax, v)
                tmax = fmax(tmax, swap_halves(tmax))
                m_new = fmax(m_run[qt], tmax)
                # A row with nothing visible yet keeps m = -inf; shift by 0 so exp2 gives 0, not NaN.
                m_use = fx.Float32((m_new == fx.Float32(_NEG_INF)).select(fx.Float32(0.0), m_new))
                a_ = exp2(fsub(m_run[qt], m_use))
                ps = [exp2(fsub(v, m_use)) for v in vals]
                rs = ps[0]
                for p in ps[1:]:
                    rs = fadd(rs, p)
                new_l.append(fadd(fmul(l_run[qt], a_), rs))
                new_m.append(m_new)
                alpha.append(a_)
                packs = [
                    to_bf16(Vec.from_elements(ps[kt * 8 : kt * 8 + 8], fx.Float32), elem)
                    for kt in range_constexpr(KT)
                ]
                p_frag.append([cat(packs[2 * pc], packs[2 * pc + 1]) for pc in range_constexpr(PC)])

            new_o = []
            for qt in range_constexpr(QT):
                new_o.append([vmul_scalar(o_acc[qt][dt], alpha[qt]) for dt in range_constexpr(DT)])
            for dt in range_constexpr(DT):
                for pc in range_constexpr(PC):
                    base = vbase + v_lane + (pc * 32 * ROW + dt * 32)
                    a = cat(lds_load_tr16(base, elem), lds_load_tr16(base + 16 * ROW, elem))
                    for qt in range_constexpr(QT):
                        new_o[qt][dt] = mma(a, p_frag[qt][pc], new_o[qt][dt])
            return new_m, new_l, new_o

        # ---- prologue: stage the first tile.
        store_kv(load_kv(t_lo), fx.Int32(0))
        gpu.barrier()

        init = []
        for _ in range_constexpr(QT):
            init.append(fx.Float32(_NEG_INF))
        for _ in range_constexpr(QT):
            init.append(fx.Float32(0.0))
        for _ in range_constexpr(QT * DT):
            init.append(Vec.filled(8, 0.0, fx.Float32))

        for t, st in range(fx.Index(t_lo), fx.Index(t_hi), fx.Index(1), init=init):
            ti = fx.Int32(t)
            m_run = [st[qt] for qt in range_constexpr(QT)]
            l_run = [st[QT + qt] for qt in range_constexpr(QT)]
            o_acc = [[st[2 * QT + qt * DT + dt] for dt in range_constexpr(DT)] for qt in range_constexpr(QT)]
            buf = (ti - t_lo) % 2
            # Prefetch the next tile into registers before the math; past the end it is all OOB.
            nxt = load_kv(ti + 1)
            m_run, l_run, o_acc = tile_compute(ti, buf, m_run, l_run, o_acc)
            store_kv(nxt, 1 - buf)
            gpu.barrier()
            out = list(m_run) + list(l_run)
            for qt in range_constexpr(QT):
                out += list(o_acc[qt])
            res = yield out

        m_fin = [res[qt] for qt in range_constexpr(QT)]
        l_fin = [res[QT + qt] for qt in range_constexpr(QT)]
        o_fin = [[res[2 * QT + qt * DT + dt] for dt in range_constexpr(DT)] for qt in range_constexpr(QT)]

        # ---- epilogue: normalise, fold the sink, store O and LSE.
        o_addr = tensor_addr(O) + (q_base + fx.Int64(q0) * fx.Int64(sq_tok) + fx.Int64(h * D)) * 2
        rsrc_o = make_rsrc(o_addr, q_rows_valid * sq_tok * 2)
        if const_expr(emit_lse):
            rsrc_lse = make_rsrc(
                tensor_addr(LSE) + fx.Int64(lse_tok0) * (HQ * 4), imax(seqlen_q, 0) * (HQ * 4)
            )
        if const_expr(has_sink):
            rsrc_sink = make_rsrc(tensor_addr(SINK), HQ * 4)
            sink_log2 = fmul(fx.Float32(buf_load(rsrc_sink, h * 4, T.f32)), LOG2E)
        for qt in range_constexpr(QT):
            m = m_fin[qt]
            l_tot = fadd(l_fin[qt], swap_halves(l_fin[qt]))
            if const_expr(has_sink):
                # The sink is a key with logit sink[h] and a zero value: it joins the
                # denominator only.
                mf = fmax(m, sink_log2)
                af = exp2(fsub(m, mf))
                l_out = fadd(fmul(l_tot, af), exp2(fsub(sink_log2, mf)))
                o_scale = fmul(af, rcp(l_out))
            else:
                mf = m
                l_out = l_tot
                o_scale = fx.Float32((l_tot > fx.Float32(0.0)).select(rcp(l_tot), fx.Float32(0.0)))
            row = wrow0 + qt * 16 + l16
            row_off = row * sq_tok * 2 + hi * 16
            for dt in range_constexpr(DT):
                o16 = to_bf16(vmul_scalar(o_fin[qt][dt], o_scale), elem)
                buf_store(o16.bitcast(fx.Int32), rsrc_o, row_off + dt * 32)
            if const_expr(emit_lse):
                lse = fmul(fadd(mf, log2(l_out)), LN2)
                # Lanes 16..31 hold the same rows; push them out of range rather than branch.
                lse_off = fx.Int32((hi == 0).select((q0 + row) * (HQ * 4) + h * 4, fx.Int32(0x7FFFFFF0)))
                buf_store(lse, rsrc_lse, lse_off)

    @flyc.jit
    def launch_flash_attn_fwd_gfx1250(
        Q: fx.Tensor,
        K: fx.Tensor,
        V: fx.Tensor,
        O: fx.Tensor,  # noqa: E741
        LSE: fx.Tensor,
        CuQ: fx.Tensor,
        CuK: fx.Tensor,
        SINK: fx.Tensor,
        batch: fx.Int32,
        seq_q: fx.Int32,
        seq_kv: fx.Int32,
        sq_tok: fx.Int32,
        skv_tok: fx.Int32,
        bs_q: fx.Int32,
        bs_kv: fx.Int32,
        stream: fx.Stream = fx.Stream(None),  # noqa: B008
    ):
        nqb = (fx.Index(seq_q) + BM - 1) // BM
        flash_attn_fwd_gfx1250_kernel(
            Q, K, V, O, LSE, CuQ, CuK, SINK, seq_q, seq_kv, sq_tok, skv_tok, bs_q, bs_kv
        ).launch(
            grid=(nqb, HQ, fx.Index(batch)),
            block=(BLOCK, 1, 1),
            stream=stream,
        )

    _compiled = {}

    def _launch(
        q,
        k,
        v,
        out,
        batch,
        seq_q,
        seq_kv,
        sq_tok,
        skv_tok,
        bs_q=0,
        bs_kv=0,
        *,
        lse=None,
        cu_seqlens_q=None,
        cu_seqlens_kv=None,
        sink=None,
        stream=None,
    ):
        """q/out: element (tok, h, d) of batch b lives at ``base_q + s*sq_tok + h*D + d``, where
        ``base_q = cu_seqlens_q[b]*sq_tok`` (varlen) or ``b*bs_q`` (dense); likewise k/v with
        the kv strides. ``seq_q`` is the max per-segment length for varlen. ``lse`` is fp32
        ``[tokens, Hq]`` with token ``cu_seqlens_q[b] + s`` (varlen) or ``b*seq_q + s``."""
        args = (
            q,
            k,
            v,
            out,
            out if lse is None else lse,
            out if cu_seqlens_q is None else cu_seqlens_q,
            out if cu_seqlens_kv is None else cu_seqlens_kv,
            out if sink is None else sink,
            int(batch),
            int(seq_q),
            int(seq_kv),
            int(sq_tok),
            int(skv_tok),
            int(bs_q),
            int(bs_kv),
        )
        if emit_lse and lse is None:
            raise ValueError("this module was built with emit_lse=True; pass lse")
        if has_sink and sink is None:
            raise ValueError("this module was built with has_sink=True; pass sink")
        fn = _compiled.get("fn")
        if fn is None:
            fn = flyc.compile(launch_flash_attn_fwd_gfx1250, *args, fx.Stream(stream))
            _compiled["fn"] = fn
        return fn(*args, stream)

    return _launch
