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

"""DeepSeek-V4 sparse-MLA attention forward for gfx1250 (MI455X): wave32, WMMA 16x16x32.

Same contract as ``sparse_mla_fwd_triton``: q ``[T, H, 576]``, a single MQA latent kv
``[NKV, 1, 576]`` whose first 512 columns are both K and V (the 64 rope columns are a zero
pad and take no part), per-token top-k row indices (``-1`` = unused slot), optional per-head
sink. Returns o ``[T, H, 512]`` and a sink-inclusive natural-log lse ``[T, H]``.

A workgroup owns one token and ``16 * waves`` of its heads; each wave owns 16 heads. The
top-k latent rows of the token are gathered into a double-buffered LDS tile shared by all
waves, and each wave runs the transposed problem ``S^T = K Q^T``, ``O^T += V^T P^T`` (see
``flash_attn_fwd_gfx1250``): a lane holds one head, so the softmax is in-lane, and V^T comes
from ``ds_load_tr16_b128`` reads of the same tile K was read from.
"""

import functools

import flydsl.compiler as flyc
import flydsl.expr as fx
import torch
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
)

_NEG_INF = float("-inf")
DV = 512  # latent width: K and V
DQK = 576  # q / kv row length (latent + zero rope pad)


@functools.lru_cache(maxsize=64)
def build_sparse_mla_fwd_gfx1250(num_heads, topk, scale, has_sink, heads_per_wg=None, block_k=None):
    """Launcher for fixed (H, topk, scale, sink); see ``sparse_mla_fwd_gfx1250``."""
    H = num_heads
    HB = heads_per_wg or min(H, 128)
    if H % HB or HB % 16:
        raise ValueError(f"num_heads {H} must split into 16-head waves (heads_per_wg={HB})")
    BN = block_k or (64 if topk % 64 == 0 else 32)
    if topk % BN or BN % 32:
        raise ValueError(f"topk {topk} must be a multiple of the kv tile {BN}")
    WAVES = HB // 16
    BLOCK = WAVES * WAVE
    NT = topk // BN
    KT = BN // 16  # 16-row kv sub-tiles
    PC = BN // 32  # 32-row P*V reduction steps
    KS = DV // 32  # QK reduction steps
    DT = DV // 16  # d tiles of O^T
    ROW = DV * 2 + 16  # LDS row pitch (bytes), 16-byte multiple for ds_load_tr16_b128
    TILE_B = BN * ROW
    LDS_B = 2 * TILE_B
    CPR = DV * 2 // 16  # 16-byte chunks per latent row
    if BLOCK % BN:
        raise ValueError("kv tile rows must divide the workgroup")
    TPR = BLOCK // BN  # threads per gathered row
    CH = CPR // TPR  # chunks per thread per tile
    c_log2 = float(scale) * LOG2E

    @flyc.kernel(known_block_size=[BLOCK, 1, 1])
    def sparse_mla_fwd_gfx1250_kernel(
        Q: fx.Tensor,
        KV: fx.Tensor,
        TOPK: fx.Tensor,
        SINK: fx.Tensor,
        O: fx.Tensor,  # noqa: E741
        LSE: fx.Tensor,
        NKV: fx.Int32,
    ):
        tid = fx.Int32(fx.thread_idx.x)
        wave = uniform(tid // WAVE)
        lane = tid % WAVE
        l16 = lane % 16
        hi = lane // 16
        l8 = lane % 8
        tok = fx.Int32(fx.block_idx.x)
        h_lane = fx.Int32(fx.block_idx.y) * HB + wave * 16 + l16

        arena = fx.SharedAllocator(static=False)
        arena.allocate(LDS_B)
        lds0 = fx.Int32(fx.Int64(fx.ptrtoint(arena.base_ptr)))

        # ---- Q fragments (B operand of S^T = K Q^T): lane holds head h_lane.
        rsrc_q = make_rsrc(tensor_addr(Q) + fx.Int64(tok) * (H * DQK * 2), H * DQK * 2)
        q_off = h_lane * (DQK * 2) + hi * 16
        q_frag = [
            cat(buf_load_b128(rsrc_q, q_off + ks * 64), buf_load_b128(rsrc_q, q_off + ks * 64 + 32))
            for ks in range_constexpr(KS)
        ]

        rsrc_idx = make_rsrc(tensor_addr(TOPK) + fx.Int64(tok) * (topk * 4), topk * 4)
        kv_bytes = NKV * (DQK * 2)
        rsrc_kv = make_rsrc(tensor_addr(KV), kv_bytes)
        v4i = vec_type(4, fx.Int32)

        # ---- gather: TPR threads per row, each moving CH strided 16-byte chunks.
        g_row = tid // TPR
        g_col = tid % TPR
        l_base = g_row * ROW + g_col * 16

        def load_tile(t):
            # Past the last tile the index read is out of range (0), harmless: never stored
            # into a buffer that is read again.
            idx = fx.Int32(buf_load(rsrc_idx, (t * BN + g_row) * 4, T.i32))
            # An unused slot reads out of range: zeros, masked out of the softmax below.
            row_off = fx.Int32((idx >= 0).select(idx * (DQK * 2), kv_bytes)) + g_col * 16
            return [buf_load(rsrc_kv, row_off + c * (TPR * 16), v4i) for c in range_constexpr(CH)]

        def store_tile(regs, buf):
            base = lds0 + buf * TILE_B + l_base
            for c in range_constexpr(CH):
                lds_store(regs[c], base + c * (TPR * 16))

        k_lane = l16 * ROW + hi * 16
        v_lane = (hi * 8 + l8) * ROW + (l16 // 8) * 16
        v8e = vec_type(8, fx.BFloat16)

        def tile_compute(t, buf, m_run, l_run, o_acc):
            kbase = lds0 + buf * TILE_B
            # Validity of the kv rows this lane's score elements cover: kt*16 + hi*8 + i.
            valid = []
            for kt in range_constexpr(KT):
                o = (t * BN + kt * 16 + hi * 8) * 4
                iv = cat(Vec(buf_load(rsrc_idx, o, v4i)), Vec(buf_load(rsrc_idx, o + 16, v4i)))
                valid.append([iv[i] >= fx.Int32(0) for i in range_constexpr(8)])
            s = [Vec.filled(8, 0.0, fx.Float32) for _ in range_constexpr(KT)]
            for kt in range_constexpr(KT):
                for ks in range_constexpr(KS):
                    a = cat(
                        lds_load(kbase + k_lane + (kt * 16 * ROW + ks * 64), v8e),
                        lds_load(kbase + k_lane + (kt * 16 * ROW + ks * 64 + 32), v8e),
                    )
                    s[kt] = wmma_bf16(a, q_frag[ks], s[kt])
            vals = []
            for kt in range_constexpr(KT):
                sv = vmul_scalar(s[kt], c_log2)
                for i in range_constexpr(8):
                    vals.append(fx.Float32(valid[kt][i].select(sv[i], fx.Float32(_NEG_INF))))
            tmax = vals[0]
            for v in vals[1:]:
                tmax = fmax(tmax, v)
            tmax = fmax(tmax, swap_halves(tmax))
            m_new = fmax(m_run, tmax)
            m_use = fx.Float32((m_new == fx.Float32(_NEG_INF)).select(fx.Float32(0.0), m_new))
            alpha = exp2(fsub(m_run, m_use))
            ps = [exp2(fsub(v, m_use)) for v in vals]
            rs = ps[0]
            for p in ps[1:]:
                rs = fadd(rs, p)
            l_new = fadd(fmul(l_run, alpha), rs)
            packs = [
                to_bf16(Vec.from_elements(ps[kt * 8 : kt * 8 + 8], fx.Float32)) for kt in range_constexpr(KT)
            ]
            p_frag = [cat(packs[2 * pc], packs[2 * pc + 1]) for pc in range_constexpr(PC)]
            new_o = [vmul_scalar(o_acc[dt], alpha) for dt in range_constexpr(DT)]
            for dt in range_constexpr(DT):
                for pc in range_constexpr(PC):
                    base = kbase + v_lane + (pc * 32 * ROW + dt * 32)
                    a = cat(lds_load_tr16(base), lds_load_tr16(base + 16 * ROW))
                    new_o[dt] = wmma_bf16(a, p_frag[pc], new_o[dt])
            return m_new, l_new, new_o

        store_tile(load_tile(fx.Int32(0)), fx.Int32(0))
        gpu.barrier()

        init = [fx.Float32(_NEG_INF), fx.Float32(0.0)] + [
            Vec.filled(8, 0.0, fx.Float32) for _ in range_constexpr(DT)
        ]
        for t, st in range(fx.Index(0), fx.Index(NT), fx.Index(1), init=init):
            ti = fx.Int32(t)
            buf = ti % 2
            nxt = load_tile(ti + 1)
            m_run, l_run, o_acc = tile_compute(
                ti, buf, st[0], st[1], [st[2 + dt] for dt in range_constexpr(DT)]
            )
            store_tile(nxt, 1 - buf)
            gpu.barrier()
            res = yield [m_run, l_run] + list(o_acc)

        m = res[0]
        l_tot = fadd(res[1], swap_halves(res[1]))
        if const_expr(has_sink):
            rsrc_sink = make_rsrc(tensor_addr(SINK), H * 4)
            sink_log2 = fmul(fx.Float32(buf_load(rsrc_sink, h_lane * 4, T.f32)), LOG2E)
            mf = fmax(m, sink_log2)
            af = exp2(fsub(m, mf))
            l_out = fadd(fmul(l_tot, af), exp2(fsub(sink_log2, mf)))
            o_scale = fmul(af, rcp(l_out))
        else:
            mf = m
            l_out = l_tot
            o_scale = fx.Float32((l_tot > fx.Float32(0.0)).select(rcp(l_tot), fx.Float32(0.0)))
        rsrc_o = make_rsrc(tensor_addr(O) + fx.Int64(tok) * (H * DV * 2), H * DV * 2)
        o_off = h_lane * (DV * 2) + hi * 16
        for dt in range_constexpr(DT):
            o16 = to_bf16(vmul_scalar(res[2 + dt], o_scale))
            buf_store(o16.bitcast(fx.Int32), rsrc_o, o_off + dt * 32)
        rsrc_lse = make_rsrc(tensor_addr(LSE) + fx.Int64(tok) * (H * 4), H * 4)
        lse = fmul(fadd(mf, log2(l_out)), LN2)
        # Lanes 16..31 hold the same heads; push their store out of range.
        buf_store(lse, rsrc_lse, fx.Int32((hi == 0).select(h_lane * 4, fx.Int32(0x7FFFFFF0))))

    @flyc.jit
    def launch_sparse_mla_fwd_gfx1250(
        Q: fx.Tensor,
        KV: fx.Tensor,
        TOPK: fx.Tensor,
        SINK: fx.Tensor,
        O: fx.Tensor,  # noqa: E741
        LSE: fx.Tensor,
        n_tok: fx.Int32,
        NKV: fx.Int32,
        stream: fx.Stream = fx.Stream(None),  # noqa: B008
    ):
        sparse_mla_fwd_gfx1250_kernel(Q, KV, TOPK, SINK, O, LSE, NKV).launch(
            grid=(fx.Index(n_tok), H // HB, 1), block=(BLOCK, 1, 1), stream=stream
        )

    compiled = {}

    def run(q, kv, topk_indices, sink, o, lse, stream=None):
        args = (q, kv, topk_indices, o if sink is None else sink, o, lse, int(q.shape[0]), int(kv.shape[0]))
        fn = compiled.get("fn")
        if fn is None:
            fn = flyc.compile(launch_sparse_mla_fwd_gfx1250, *args, fx.Stream(stream))
            compiled["fn"] = fn
        return fn(*args, stream)

    return run


def sparse_mla_fwd_gfx1250(q, kv, topk_indices, attn_sink=None, kv_lora_rank=512, scale=None, stream=None):
    """o ``[T, H, 512]`` (q.dtype) and lse ``[T, H]`` fp32; see the module docstring."""
    assert kv_lora_rank == DV and q.shape[-1] == DQK, "gfx1250 sparse-MLA is the 512 + 64 latent layout"
    assert q.dtype == torch.bfloat16 and q.is_contiguous() and topk_indices.is_contiguous()
    T_, H, _ = q.shape
    topk = topk_indices.shape[1]
    if scale is None:
        scale = 1.0 / DQK**0.5
    kv = kv.reshape(kv.shape[0], DQK)
    assert kv.is_contiguous() and topk_indices.dtype == torch.int32
    if attn_sink is not None:
        assert attn_sink.dtype == torch.float32 and attn_sink.shape == (H,)
        attn_sink = attn_sink.contiguous()
    o = torch.empty(T_, H, DV, dtype=q.dtype, device=q.device)
    lse = torch.empty(T_, H, dtype=torch.float32, device=q.device)
    if T_ == 0:
        return o, lse
    run = build_sparse_mla_fwd_gfx1250(H, topk, float(scale), attn_sink is not None)
    run(q, kv, topk_indices, attn_sink, o, lse, stream=stream)
    return o, lse
