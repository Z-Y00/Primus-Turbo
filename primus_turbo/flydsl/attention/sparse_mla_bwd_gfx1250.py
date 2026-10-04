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

One fused kernel per token, all heads in one workgroup (16 heads per wave group; with fewer
than 128 heads, two waves share a group and split its slots and dQ^T columns):

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
_LDS_CAP = 320 * 1024
# Per-chunk bound on the dKV intermediate. Besides capping memory, the gather's scattered row
# reads run ~2.5x faster once the buffer spans less than ~2 GB.
_INTERM_BYTES = 1536 << 20


@functools.lru_cache(maxsize=64)
def build_sparse_mla_bwd_gfx1250(num_heads, topk, scale, block_k=32, d_split=None):
    H = num_heads
    if H % 32 or 128 % H:
        raise ValueError(f"gfx1250 sparse-MLA backward needs num_heads in (32, 64, 128), got {H}")
    BN = block_k
    if topk % BN or BN % 32:
        raise ValueError(f"topk {topk} must be a multiple of the kv tile {BN}")
    HG = H // 16  # 16-head groups
    KT = BN // 16  # 16-slot sub-tiles
    # Waves per head group: they split the S / dP slot sub-tiles and the dQ^T d range, so small
    # head counts still run 8 waves.
    DS = d_split or max(1, min(8 // HG, KT))
    WAVES = HG * DS
    BLOCK = WAVES * WAVE
    NT = topk // BN
    KTW = KT // DS  # slot sub-tiles per wave (S, dP)
    PC = BN // 32  # 32-slot reduction steps (dQ)
    KS = DV // 32  # d reduction steps (S, dP)
    DT = DV // 16  # d tiles of dQ^T
    DTQ = DT // DS  # dQ^T d tiles per wave
    HC = H // 32  # head reduction steps (dKV)
    DTW = DT // WAVES  # d tiles of C^T per wave
    RZ = (DQK - DV) * 2 // 32  # 16-byte rope-zero chunks per half row of dq
    if KT % DS or DT % WAVES or RZ % DS:
        raise ValueError(f"d_split {DS} does not divide the tile for num_heads {H}")
    ROW = DV * 2 + 16  # LDS pitch of latent rows (bytes)
    SP = H * 2 + 16  # LDS pitch of the [slot][head] dS / P tiles (bytes)
    QO_B = H * ROW
    TILE_B = BN * ROW
    DS_B = BN * SP
    fixed = 2 * QO_B + 2 * DS_B + DS * H * 4
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
        hg = wave % HG
        ds = wave // HG
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
        kv_lds = dl_lds + DS * H * 4

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

        # ---- delta = rowsum(O * dO), dO from LDS: lane (l16, hi) of split ds sums part ds*2 + hi
        # of head hg*16 + l16; the DS partials are summed when read back.
        h_own = hg * 16 + l16
        CPP = CPR // (2 * DS)
        part = ds * 2 + hi
        o_regs = [buf_load(rsrc_o, h_own * (DV * 2) + (part * CPP + j) * 16, v4i) for j in range_constexpr(CPP)]
        gpu.barrier()
        acc = fx.Float32(0.0)
        for j in range_constexpr(CPP):
            off = (part * CPP + j) * 16
            ov = Vec(o_regs[j]).bitcast(fx.BFloat16)
            dv = Vec(lds_load(do_lds + h_own * ROW + off, v4i)).bitcast(fx.BFloat16)
            for e in range_constexpr(8):
                acc = fadd(acc, fmul(fx.Float32(ov[e]), fx.Float32(dv[e])))
        lds_store(fadd(acc, swap_halves(acc)), dl_lds + (ds * H + h_own) * 4, align=4)

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

        delta_own = fx.Float32(lds_load(dl_lds + h_own * 4, T.f32, align=4))
        for k in range_constexpr(1, DS):
            delta_own = fadd(delta_own, fx.Float32(lds_load(dl_lds + (k * H + h_own) * 4, T.f32, align=4)))
        rsrc_dl = make_rsrc(tensor_addr(DELTA) + fx.Int64(tok) * (H * 4), H * 4)
        buf_store(delta_own, rsrc_dl, fx.Int32((part == 0).select(h_own * 4, fx.Int32(0x7FFFFFF0))))

        # Per-lane row statistics for heads hg*16 + hi*8 + i (rows of this lane's S tile).
        rsrc_lse = make_rsrc(tensor_addr(LSE) + fx.Int64(tok) * (H * 4), H * 4)
        hrow = hg * 16 + hi * 8
        lsev = cat(Vec(buf_load(rsrc_lse, hrow * 4, v4f)), Vec(buf_load(rsrc_lse, hrow * 4 + 16, v4f)))
        dlt = [fx.Float32(0.0)] * 8
        for k in range_constexpr(DS):
            o = dl_lds + (k * H + hrow) * 4
            dlv = cat(lds_load(o, v4f), lds_load(o + 16, v4f))
            dlt = [fadd(dlt[i], fx.Float32(dlv[i])) for i in range_constexpr(8)]
        lse2 = []
        for i in range_constexpr(8):
            l_ = fx.Float32(lsev[i])
            # No visible key and no sink: lse = -inf, P must be 0.
            lse2.append(
                fx.Float32(
                    (l_ == fx.Float32(float("-inf"))).select(fx.Float32(float("inf")), fmul(l_, LOG2E))
                )
            )

        a_lane = l16 * ROW + hi * 16  # non-transposed fragment read (lane = row)
        tr_lane = (hi * 8 + l8) * ROW + (l16 // 8) * 16
        tr_ds = (hi * 8 + l8) * SP + (l16 // 8) * 16
        q_row = q_lds + (hg * 16) * ROW + a_lane
        do_row = do_lds + (hg * 16) * ROW + a_lane
        kt0 = ds * KTW  # first slot sub-tile of this wave
        dt0 = ds * DTQ  # first dQ^T d tile of this wave
        interm_tok = fx.Int64(tok) * fx.Int64(topk * DV * 2)
        rsrc_im = make_rsrc(tensor_addr(INTERM) + interm_tok, topk * DV * 2)

        def tile_compute(t, buf, dq_acc):
            kbase = kv_lds + buf * TILE_B
            kb_w = kbase + a_lane + kt0 * 16 * ROW
            s = [Vec.filled(8, 0.0, fx.Float32) for _ in range_constexpr(KTW)]
            dp = [Vec.filled(8, 0.0, fx.Float32) for _ in range_constexpr(KTW)]
            for ks in range_constexpr(KS):
                aq = cat(lds_load(q_row + ks * 64, v8e), lds_load(q_row + ks * 64 + 32, v8e))
                ad = cat(lds_load(do_row + ks * 64, v8e), lds_load(do_row + ks * 64 + 32, v8e))
                for kk in range_constexpr(KTW):
                    o = kb_w + kk * 16 * ROW + ks * 64
                    bk = cat(lds_load(o, v8e), lds_load(o + 32, v8e))
                    s[kk] = wmma_bf16(aq, bk, s[kk])
                    dp[kk] = wmma_bf16(ad, bk, dp[kk])
            # P, dS: lane = slot t*BN + kt*16 + l16, element i = head hg*16 + hi*8 + i.
            for kk in range_constexpr(KTW):
                kt = kt0 + kk
                idx = fx.Int32(buf_load(rsrc_idx, (t * BN + kt * 16 + l16) * 4, T.i32))
                ok = idx >= fx.Int32(0)
                sv = vmul_scalar(s[kk], c_log2)
                pv, dsv = [], []
                for i in range_constexpr(8):
                    p = fx.Float32(ok.select(exp2(fsub(sv[i], lse2[i])), fx.Float32(0.0)))
                    pv.append(p)
                    dsv.append(fmul(fmul(p, fsub(dp[kk][i], dlt[i])), scale))
                slot_off = (kt * 16 + l16) * SP + hrow * 2
                lds_store(to_bf16(Vec.from_elements(dsv, fx.Float32)), ds_lds + slot_off)
                lds_store(to_bf16(Vec.from_elements(pv, fx.Float32)), p_lds + slot_off)
            gpu.barrier()
            # dQ^T[d, own heads] += K^T[d, slot] dS^T[slot, h].
            new = list(dq_acc)
            for pc in range_constexpr(PC):
                bb = ds_lds + tr_ds + pc * 32 * SP + hg * 32
                b = cat(lds_load_tr16(bb), lds_load_tr16(bb + 16 * SP))
                for j in range_constexpr(DTQ):
                    ab = kbase + tr_lane + pc * 32 * ROW + (dt0 + j) * 32
                    a = cat(lds_load_tr16(ab), lds_load_tr16(ab + 16 * ROW))
                    new[j] = wmma_bf16(a, b, new[j])
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

        init = [Vec.filled(8, 0.0, fx.Float32) for _ in range_constexpr(DTQ)]
        for t, st in range(fx.Index(0), fx.Index(NT), fx.Index(1), init=init):
            ti = fx.Int32(t)
            nxt = load_tile(ti + 1)
            if const_expr(NBUF == 2):
                buf = ti % 2
                acc_ = tile_compute(ti, buf, [st[j] for j in range_constexpr(DTQ)])
                store_tile(nxt, 1 - buf)
                gpu.barrier()
            else:
                acc_ = tile_compute(ti, fx.Int32(0), [st[j] for j in range_constexpr(DTQ)])
                gpu.barrier()
                store_tile(nxt, fx.Int32(0))
                gpu.barrier()
            res = yield list(acc_)

        # dQ^T tiles: lane holds head hg*16 + l16, d rows (dt0 + j)*16 + hi*8 + [0..7].
        rsrc_dq = make_rsrc(tensor_addr(DQ) + tok_q, H * DQK * 2)
        dq_off = h_own * (DQK * 2) + hi * 16
        for j in range_constexpr(DTQ):
            buf_store(to_bf16(res[j]).bitcast(fx.Int32), rsrc_dq, dq_off + (dt0 + j) * 32)
        zero = Vec.filled(4, 0, fx.Int32)
        rz_off = h_own * (DQK * 2) + DV * 2 + hi * (RZ * 16) + ds * (RZ // DS * 16)
        for j in range_constexpr(RZ // DS):
            buf_store(zero, rsrc_dq, rz_off + j * 16)

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


@functools.lru_cache(maxsize=None)
def _num_cus(device):
    return torch.cuda.get_device_properties(device).multi_processor_count


def _inverted_topk(topk_indices, num_kv):
    """CSR inverse of the top-k map: ``inv_data`` lists flat ``(tok, slot)`` indices grouped by kv
    row in stable order (invalid entries first, skipped by ``inv_ptr[0]``). Built from the sorted
    keys alone, so no host sync."""
    flat = topk_indices.reshape(-1)
    if num_kv < torch.iinfo(torch.int16).max:
        flat = flat.to(torch.int16)  # half the radix passes
    keys, inv_data = torch.sort(flat, stable=True)
    bounds = torch.arange(num_kv + 1, device=keys.device, dtype=keys.dtype)
    inv_ptr = torch.searchsorted(keys, bounds, out_int32=True)
    return inv_ptr, inv_data.to(torch.int32)


def sparse_mla_bwd_gfx1250(
    q,
    kv,
    o,
    do,
    topk_indices,
    lse,
    attn_sink=None,
    kv_lora_rank=512,
    scale=None,
    stream=None,
    interm_bytes=_INTERM_BYTES,
):
    """``(dq, dkv, dsink)``; dkv is shaped like ``kv`` and dsink is ``None`` without a sink.

    Tokens are processed in chunks whose bf16 ``[tokens, topk, 512]`` intermediate fits in
    ``interm_bytes`` (no chunking when ``None``)."""
    # Deferred: primus_turbo.triton imports primus_turbo.pytorch, which imports this module.
    from primus_turbo.triton.attention.sparse_mla import _bwd_dkv_gather_acc

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
    # One workgroup per token and per CU: chunks are whole multiples of the CU count.
    cus = _num_cus(q.device)
    units = -(-T_ // cus)
    n_chunks = 1 if interm_bytes is None else -(-T_ * topk * DV * 2 // interm_bytes)
    n_chunks = max(1, min(n_chunks, units))
    chunk = -(-units // n_chunks) * cus
    interm = torch.empty(chunk, topk, DV, dtype=torch.bfloat16, device=q.device)
    dkv_acc = torch.zeros(num_kv, DQK, dtype=torch.float32, device=q.device)
    if T_ > 0:
        run = build_sparse_mla_bwd_gfx1250(H, topk, float(scale))
        for t0 in range(0, T_, chunk):
            t1 = min(t0 + chunk, T_)
            idx = topk_indices[t0:t1]
            im = interm[: t1 - t0]
            run(q[t0:t1], kv2, o[t0:t1], do[t0:t1], idx, lse[t0:t1], dq[t0:t1], delta[t0:t1], im, stream=stream)
            inv_ptr, inv_data = _inverted_topk(idx, num_kv)
            _bwd_dkv_gather_acc[(num_kv,)](
                im, inv_ptr, inv_data, dkv_acc, DV, DQK, D_V=DV, D_ROPE=DQK - DV, HAS_ROPE=False, num_warps=4
            )
    dsink = None
    if attn_sink is not None:
        dsink = -(torch.exp(attn_sink.unsqueeze(0) - lse) * delta).sum(0)
    return dq, dkv_acc.to(kv.dtype).view(kv_shape), dsink
