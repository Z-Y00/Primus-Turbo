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

"""DeepSeek-V4 sparse-MLA attention backward for gfx1250 (MI455X): wave32, WMMA 16x16x32.

Same contract as ``sparse_mla_bwd_triton`` (dq / dkv rope columns are zero, dsink from
``delta`` and ``lse``), deterministic: no atomics.

One fused kernel per token, all heads in one workgroup (16 heads per wave):

1. ``S = Q K^T`` and ``dP = dO K^T`` with heads as rows, so a lane holds one top-k slot and
   eight heads; with lse known, ``P`` and ``dS = P (dP - delta) scale`` are elementwise.
2. ``dS`` and ``P`` go to LDS as ``[slot][head]``.
3. ``dQ^T += K^T dS^T`` per wave (both operands are ``ds_load_tr16_b128`` reads).
4. Waves split the latent width and form each slot's dKV contribution
   ``C^T = Q^T dS + dO^T P`` (reduction over all heads, Q / dO staged in LDS), written to a
   bf16 ``[T, topk, 512]`` intermediate.

The intermediate is reduced per kv row through the CSR inverse of the top-k map by the
Triton gather kernel the Triton backend uses.
"""

import functools

import flydsl.compiler as flyc
import flydsl.expr as fx
import torch
from flydsl.expr import const_expr, gpu, range_constexpr
from flydsl.expr.typing import T
from flydsl.expr.typing import Vector as Vec

from primus_turbo.flydsl.attention.sparse_mla_fwd_gfx1250 import DQK, DV
from primus_turbo.flydsl.utils.attn_helper_gfx1250 import (
    LOG2E,
    WAVE,
    buf_load,
    buf_store,
    cat,
    exp2,
    fadd,
    fmul,
    fsub,
    lds_load,
    lds_load_tr16,
    lds_store,
    make_rsrc,
    swap_halves,
    tensor_addr,
    to_bf16,
    uniform,
    vec_type,
    vmul_scalar,
    wmma_bf16,
)
from primus_turbo.triton.attention.sparse_mla import _bwd_dkv_gather_acc

_LDS_CAP = 320 * 1024


@functools.lru_cache(maxsize=64)
def build_sparse_mla_bwd_gfx1250(num_heads, topk, scale, block_k=32):
    H = num_heads
    if H % 32 or H > 128:
        raise ValueError(f"gfx1250 sparse-MLA backward needs num_heads % 32 == 0 and <= 128, got {H}")
    BN = block_k
    if topk % BN or BN % 32:
        raise ValueError(f"topk {topk} must be a multiple of the kv tile {BN}")
    WAVES = H // 16
    BLOCK = WAVES * WAVE
    NT = topk // BN
    KT = BN // 16  # 16-slot sub-tiles
    PC = BN // 32  # 32-slot reduction steps (dQ)
    KS = DV // 32  # d reduction steps (S, dP)
    DT = DV // 16  # d tiles of dQ^T
    HC = H // 32  # head reduction steps (dKV)
    DTW = DT // WAVES  # d tiles of C^T per wave
    ROW = DV * 2 + 16  # LDS pitch of latent rows (bytes)
    SP = H * 2 + 16  # LDS pitch of the [slot][head] dS / P tiles (bytes)
    QO_B = H * ROW
    TILE_B = BN * ROW
    DS_B = BN * SP
    fixed = 2 * QO_B + 2 * DS_B + H * 4
    NBUF = 2 if fixed + 2 * TILE_B <= _LDS_CAP else 1
    if fixed + NBUF * TILE_B > _LDS_CAP:
        raise ValueError("sparse-MLA backward tile does not fit in LDS")
    CPR = DV * 2 // 16  # 16-byte chunks per latent row
    TPR = BLOCK // BN
    CH = CPR // TPR
    QCH = H * CPR // BLOCK  # staging chunks per thread for Q / dO
    c_log2 = float(scale) * LOG2E

    @flyc.kernel(known_block_size=[BLOCK, 1, 1])
    def sparse_mla_bwd_gfx1250_kernel(
        Q: fx.Tensor,
        KV: fx.Tensor,
        O: fx.Tensor,  # noqa: E741
        DO: fx.Tensor,
        TOPK: fx.Tensor,
        LSE: fx.Tensor,
        DQ: fx.Tensor,
        DELTA: fx.Tensor,
        INTERM: fx.Tensor,
        NKV: fx.Int32,
    ):
        tid = fx.Int32(fx.thread_idx.x)
        wave = uniform(tid // WAVE)
        lane = tid % WAVE
        l16 = lane % 16
        hi = lane // 16
        l8 = lane % 8
        tok = fx.Int32(fx.block_idx.x)

        arena = fx.SharedAllocator(static=False)
        arena.allocate(fixed + NBUF * TILE_B)
        lds0 = fx.Int32(fx.Int64(fx.ptrtoint(arena.base_ptr)))
        q_lds = lds0
        do_lds = lds0 + QO_B
        ds_lds = lds0 + 2 * QO_B
        p_lds = ds_lds + DS_B
        dl_lds = p_lds + DS_B
        kv_lds = dl_lds + H * 4

        v4i = vec_type(4, fx.Int32)
        v4f = vec_type(4, fx.Float32)
        v8e = vec_type(8, fx.BFloat16)
        tok_q = fx.Int64(tok) * (H * DQK * 2)
        tok_o = fx.Int64(tok) * (H * DV * 2)
        rsrc_q = make_rsrc(tensor_addr(Q) + tok_q, H * DQK * 2)
        rsrc_do = make_rsrc(tensor_addr(DO) + tok_o, H * DV * 2)
        rsrc_o = make_rsrc(tensor_addr(O) + tok_o, H * DV * 2)
        rsrc_idx = make_rsrc(tensor_addr(TOPK) + fx.Int64(tok) * (topk * 4), topk * 4)
        kv_bytes = NKV * (DQK * 2)
        rsrc_kv = make_rsrc(tensor_addr(KV), kv_bytes)

        # ---- stage Q and dO (all heads) in LDS.
        for c in range_constexpr(QCH):
            idx = tid + c * BLOCK
            r, col = idx // CPR, idx % CPR
            lds_store(buf_load(rsrc_q, r * (DQK * 2) + col * 16, v4i), q_lds + r * ROW + col * 16)
            lds_store(buf_load(rsrc_do, r * (DV * 2) + col * 16, v4i), do_lds + r * ROW + col * 16)

        # ---- delta = rowsum(O * dO): lane (l16, hi) sums half of head wave*16 + l16.
        h_own = wave * 16 + l16
        acc = fx.Float32(0.0)
        for j in range_constexpr(CPR // 2):
            off = (hi * (CPR // 2) + j) * 16
            ov = Vec(buf_load(rsrc_o, h_own * (DV * 2) + off, v4i)).bitcast(fx.BFloat16)
            dv = Vec(buf_load(rsrc_do, h_own * (DV * 2) + off, v4i)).bitcast(fx.BFloat16)
            for e in range_constexpr(8):
                acc = fadd(acc, fmul(fx.Float32(ov[e]), fx.Float32(dv[e])))
        delta_own = fadd(acc, swap_halves(acc))
        rsrc_dl = make_rsrc(tensor_addr(DELTA) + fx.Int64(tok) * (H * 4), H * 4)
        dl_off = fx.Int32((hi == 0).select(h_own * 4, fx.Int32(0x7FFFFFF0)))
        buf_store(delta_own, rsrc_dl, dl_off)
        lds_store(delta_own, dl_lds + h_own * 4, align=4)

        # ---- KV gather (same scheme as the forward).
        g_row = tid // TPR
        g_col = tid % TPR

        def load_tile(t):
            idx = fx.Int32(buf_load(rsrc_idx, (t * BN + g_row) * 4, T.i32))
            row_off = fx.Int32((idx >= 0).select(idx * (DQK * 2), kv_bytes)) + g_col * 16
            return [buf_load(rsrc_kv, row_off + c * (TPR * 16), v4i) for c in range_constexpr(CH)]

        def store_tile(regs, buf):
            base = kv_lds + buf * TILE_B + g_row * ROW + g_col * 16
            for c in range_constexpr(CH):
                lds_store(regs[c], base + c * (TPR * 16))

        store_tile(load_tile(fx.Int32(0)), fx.Int32(0))
        gpu.barrier()

        # Per-lane row statistics for heads wave*16 + hi*8 + i (rows of this lane's S tile).
        rsrc_lse = make_rsrc(tensor_addr(LSE) + fx.Int64(tok) * (H * 4), H * 4)
        hrow = wave * 16 + hi * 8
        lsev = cat(Vec(buf_load(rsrc_lse, hrow * 4, v4f)), Vec(buf_load(rsrc_lse, hrow * 4 + 16, v4f)))
        dlv = cat(lds_load(dl_lds + hrow * 4, v4f), lds_load(dl_lds + hrow * 4 + 16, v4f))
        lse2 = []
        for i in range_constexpr(8):
            l_ = fx.Float32(lsev[i])
            # No visible key and no sink: lse = -inf, P must be 0.
            lse2.append(
                fx.Float32(
                    (l_ == fx.Float32(float("-inf"))).select(fx.Float32(float("inf")), fmul(l_, LOG2E))
                )
            )
        dlt = [fx.Float32(dlv[i]) for i in range_constexpr(8)]

        a_lane = l16 * ROW + hi * 16  # non-transposed fragment read (lane = row)
        tr_lane = (hi * 8 + l8) * ROW + (l16 // 8) * 16
        tr_ds = (hi * 8 + l8) * SP + (l16 // 8) * 16
        q_row = q_lds + (wave * 16) * ROW + a_lane
        do_row = do_lds + (wave * 16) * ROW + a_lane
        interm_tok = fx.Int64(tok) * fx.Int64(topk * DV * 2)
        rsrc_im = make_rsrc(tensor_addr(INTERM) + interm_tok, topk * DV * 2)

        def tile_compute(t, buf, dq_acc):
            kbase = kv_lds + buf * TILE_B
            s = [Vec.filled(8, 0.0, fx.Float32) for _ in range_constexpr(KT)]
            dp = [Vec.filled(8, 0.0, fx.Float32) for _ in range_constexpr(KT)]
            for ks in range_constexpr(KS):
                aq = cat(lds_load(q_row + ks * 64, v8e), lds_load(q_row + ks * 64 + 32, v8e))
                ad = cat(lds_load(do_row + ks * 64, v8e), lds_load(do_row + ks * 64 + 32, v8e))
                for kt in range_constexpr(KT):
                    o = kbase + a_lane + kt * 16 * ROW + ks * 64
                    bk = cat(lds_load(o, v8e), lds_load(o + 32, v8e))
                    s[kt] = wmma_bf16(aq, bk, s[kt])
                    dp[kt] = wmma_bf16(ad, bk, dp[kt])
            # P, dS: lane = slot t*BN + kt*16 + l16, element i = head wave*16 + hi*8 + i.
            for kt in range_constexpr(KT):
                idx = fx.Int32(buf_load(rsrc_idx, (t * BN + kt * 16 + l16) * 4, T.i32))
                ok = idx >= fx.Int32(0)
                sv = vmul_scalar(s[kt], c_log2)
                pv, dsv = [], []
                for i in range_constexpr(8):
                    p = fx.Float32(ok.select(exp2(fsub(sv[i], lse2[i])), fx.Float32(0.0)))
                    pv.append(p)
                    dsv.append(fmul(fmul(p, fsub(dp[kt][i], dlt[i])), scale))
                slot_off = (kt * 16 + l16) * SP + hrow * 2
                lds_store(to_bf16(Vec.from_elements(dsv, fx.Float32)), ds_lds + slot_off)
                lds_store(to_bf16(Vec.from_elements(pv, fx.Float32)), p_lds + slot_off)
            gpu.barrier()
            # dQ^T[d, own heads] += K^T[d, slot] dS^T[slot, h].
            new = list(dq_acc)
            for pc in range_constexpr(PC):
                bb = ds_lds + tr_ds + pc * 32 * SP + wave * 32
                b = cat(lds_load_tr16(bb), lds_load_tr16(bb + 16 * SP))
                for dt in range_constexpr(DT):
                    ab = kbase + tr_lane + pc * 32 * ROW + dt * 32
                    a = cat(lds_load_tr16(ab), lds_load_tr16(ab + 16 * ROW))
                    new[dt] = wmma_bf16(a, b, new[dt])
            # C^T[d, slot] = Q^T dS + dO^T P over this wave's d tiles.
            for kt in range_constexpr(KT):
                bs, bp = [], []
                for hc in range_constexpr(HC):
                    o = (kt * 16 + l16) * SP + hc * 64 + hi * 16
                    bs.append(cat(lds_load(ds_lds + o, v8e), lds_load(ds_lds + o + 32, v8e)))
                    bp.append(cat(lds_load(p_lds + o, v8e), lds_load(p_lds + o + 32, v8e)))
                for j in range_constexpr(DTW):
                    dt = wave * DTW + j
                    c = Vec.filled(8, 0.0, fx.Float32)
                    for hc in range_constexpr(HC):
                        aq = q_lds + tr_lane + hc * 32 * ROW + dt * 32
                        ad = do_lds + tr_lane + hc * 32 * ROW + dt * 32
                        c = wmma_bf16(cat(lds_load_tr16(aq), lds_load_tr16(aq + 16 * ROW)), bs[hc], c)
                        c = wmma_bf16(cat(lds_load_tr16(ad), lds_load_tr16(ad + 16 * ROW)), bp[hc], c)
                    im_off = (t * BN + kt * 16 + l16) * (DV * 2) + dt * 32 + hi * 16
                    buf_store(to_bf16(c).bitcast(fx.Int32), rsrc_im, im_off)
            return new

        init = [Vec.filled(8, 0.0, fx.Float32) for _ in range_constexpr(DT)]
        for t, st in range(fx.Index(0), fx.Index(NT), fx.Index(1), init=init):
            ti = fx.Int32(t)
            nxt = load_tile(ti + 1)
            if const_expr(NBUF == 2):
                buf = ti % 2
                acc_ = tile_compute(ti, buf, [st[dt] for dt in range_constexpr(DT)])
                store_tile(nxt, 1 - buf)
                gpu.barrier()
            else:
                acc_ = tile_compute(ti, fx.Int32(0), [st[dt] for dt in range_constexpr(DT)])
                gpu.barrier()
                store_tile(nxt, fx.Int32(0))
                gpu.barrier()
            res = yield list(acc_)

        # dQ^T tiles: lane holds head wave*16 + l16, d rows dt*16 + hi*8 + [0..7].
        rsrc_dq = make_rsrc(tensor_addr(DQ) + tok_q, H * DQK * 2)
        dq_off = h_own * (DQK * 2) + hi * 16
        for dt in range_constexpr(DT):
            buf_store(to_bf16(res[dt]).bitcast(fx.Int32), rsrc_dq, dq_off + dt * 32)
        zero = Vec.filled(4, 0, fx.Int32)
        for j in range_constexpr((DQK - DV) * 2 // 32):
            buf_store(zero, rsrc_dq, h_own * (DQK * 2) + DV * 2 + hi * ((DQK - DV) * 2 // 2) + j * 16)

    @flyc.jit
    def launch_sparse_mla_bwd_gfx1250(
        Q: fx.Tensor,
        KV: fx.Tensor,
        O: fx.Tensor,  # noqa: E741
        DO: fx.Tensor,
        TOPK: fx.Tensor,
        LSE: fx.Tensor,
        DQ: fx.Tensor,
        DELTA: fx.Tensor,
        INTERM: fx.Tensor,
        n_tok: fx.Int32,
        NKV: fx.Int32,
        stream: fx.Stream = fx.Stream(None),  # noqa: B008
    ):
        sparse_mla_bwd_gfx1250_kernel(Q, KV, O, DO, TOPK, LSE, DQ, DELTA, INTERM, NKV).launch(
            grid=(fx.Index(n_tok), 1, 1), block=(BLOCK, 1, 1), stream=stream
        )

    compiled = {}

    def run(q, kv, o, do, topk_indices, lse, dq, delta, interm, stream=None):
        args = (q, kv, o, do, topk_indices, lse, dq, delta, interm, int(q.shape[0]), int(kv.shape[0]))
        fn = compiled.get("fn")
        if fn is None:
            fn = flyc.compile(launch_sparse_mla_bwd_gfx1250, *args, fx.Stream(stream))
            compiled["fn"] = fn
        return fn(*args, stream)

    return run


def _inverted_topk(topk_indices, num_kv):
    """CSR inverse of the top-k map: ``inv_data`` lists flat ``(tok, slot)`` indices grouped by kv
    row in stable order (invalid entries first, skipped by ``inv_ptr[0]``). Built from the sorted
    keys alone, so no host sync."""
    keys, inv_data = torch.sort(topk_indices.reshape(-1), stable=True)
    bounds = torch.arange(num_kv + 1, device=keys.device, dtype=keys.dtype)
    inv_ptr = torch.searchsorted(keys, bounds, out_int32=True)
    return inv_ptr, inv_data.to(torch.int32)


def sparse_mla_bwd_gfx1250(
    q, kv, o, do, topk_indices, lse, attn_sink=None, kv_lora_rank=512, scale=None, stream=None
):
    """``(dq, dkv, dsink)``; dkv is shaped like ``kv`` and dsink is ``None`` without a sink."""
    assert kv_lora_rank == DV and q.shape[-1] == DQK, "gfx1250 sparse-MLA is the 512 + 64 latent layout"
    for x in (q, o, do, topk_indices, lse):
        assert x.is_contiguous()
    T_, H, _ = q.shape
    topk = topk_indices.shape[1]
    if scale is None:
        scale = 1.0 / DQK**0.5
    kv_shape = kv.shape
    kv2 = kv.reshape(kv.shape[0], DQK)
    assert kv2.is_contiguous()
    num_kv = kv2.shape[0]
    dq = torch.empty_like(q)
    delta = torch.empty(T_, H, dtype=torch.float32, device=q.device)
    interm = torch.empty(T_, topk, DV, dtype=torch.bfloat16, device=q.device)
    dkv_acc = torch.zeros(num_kv, DQK, dtype=torch.float32, device=q.device)
    if T_ > 0:
        run = build_sparse_mla_bwd_gfx1250(H, topk, float(scale))
        run(q, kv2, o, do, topk_indices, lse, dq, delta, interm, stream=stream)
        inv_ptr, inv_data = _inverted_topk(topk_indices, num_kv)
        _bwd_dkv_gather_acc[(num_kv,)](
            interm, inv_ptr, inv_data, dkv_acc, DV, DQK, D_V=DV, D_ROPE=DQK - DV, HAS_ROPE=False, num_warps=4
        )
    dsink = None
    if attn_sink is not None:
        dsink = -(torch.exp(attn_sink.unsqueeze(0) - lse) * delta).sum(0)
    return dq, dkv_acc.to(kv.dtype).view(kv_shape), dsink
