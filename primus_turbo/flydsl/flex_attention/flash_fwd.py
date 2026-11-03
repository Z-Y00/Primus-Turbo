###############################################################################
# Copyright (c) 2026, Advanced Micro Devices, Inc. All rights reserved.
#
# See LICENSE for license information.
###############################################################################

"""Flash attention forward in FlyDSL, structured after FA4's ``FlashAttentionForwardSm80``
(``flash_attn/cute/flash_fwd.py``) and written for CDNA's wave64 MFMA (gfx942 first).

Layout. A CTA holds ``num_waves`` waves; each wave owns 32 query rows. Scores are
computed transposed, S^T = K . Q^T, with MFMA 32x32x8, so each lane holds one query
row (the accumulator column) and 16 of a 32-key tile's scores for it -- the rest sit
in lane ``^ 32``. That keeps the softmax reductions in-lane plus one shuffle, and lets
the probabilities feed the PV product without any data movement: accumulator group
``g`` (elements ``4g .. 4g+3``) is exactly the B fragment of reduction step ``g`` of
O^T = V^T . P^T. Q lives in registers for the whole loop; each KV tile is staged
global -> registers -> LDS once per CTA and read by every wave. Rows past a sequence's
end are loaded clamped to its last row (never out of bounds) and masked away.

Tensors follow FA4. Dense: q ``[B, Sq, Hq, D]``, k ``[B, Sk, Hk, D]``,
v ``[B, Sk, Hk, Dv]``, out ``[B, Sq, Hq, Dv]``, lse ``[B, Hq, Sq]`` (fp32, natural log).
With ``cu_seqlens_q`` the query side is packed instead -- q / out ``[Tq, H, D]``, lse
``[Hq, Tq]`` -- and likewise k / v with ``cu_seqlens_k``. ``seqused_q`` / ``seqused_k``
override the per-sequence lengths. Shapes and strides are read at runtime, so one
compiled kernel serves every length.

Mods follow FA4 (see ``mods.py``): ``score_mod`` gets the score times ``softmax_scale``
and runs before the change to base 2; ``mask_mod`` is and-ed into the causal / window /
length mask. Both are traced into the kernel and may read up to ``MAX_AUX_TENSORS``
aux tensors. ``learnable_sink`` (fp32 ``[Hq]``) adds one value-less logit per head to
the softmax denominator.
"""

import flydsl.compiler as flyc
import flydsl.expr as fx
from flydsl.expr import range_constexpr
from flydsl.expr.typing import Vector as Vec

from primus_turbo.flydsl.flex_attention.block_info import BlockInfo
from primus_turbo.flydsl.flex_attention.block_sparsity import broadcast_heads, subtile_factors
from primus_turbo.flydsl.flex_attention.mask import AttentionMask
from primus_turbo.flydsl.flex_attention.seqlen_info import SeqlenInfo
from primus_turbo.flydsl.flex_attention.softmax import LOG2E, Softmax

MFMA_M = 32
K_STEP = 8  # MFMA 32x32x8: four elements per lane per operand
MAX_AUX_TENSORS = 4


def _min(a, b):
    return (a < b).select(a, b)


# Static dispatch lives outside the kernel body: the AST rewriter turns an ``if`` there
# into branch closures that do not see the kernel's other locals.
def _apply_score_mod(score_mod, score, batch, head, q_pos, kv_pos, mask: AttentionMask):
    if score_mod is None:
        return score
    return score_mod(score, batch, head, mask.clamp_q(q_pos), mask.clamp_kv(kv_pos), mask.seqlen, mask.aux_tensors)


def _sink_log2(has_sink, sink, head):
    if not has_sink:
        return None
    return fx.Float32(fx.rocdl.make_buffer_tensor(sink)[head]) * fx.Float32(LOG2E)


class FlashAttentionForward:
    """Builds and caches the launcher for one compile-time configuration."""

    def __init__(
        self,
        dtype: str = "bf16",
        head_dim: int = 128,
        head_dim_v: int | None = None,
        qhead_per_kvhead: int = 1,
        is_causal: bool = False,
        is_local: bool = False,
        tile_n: int = 64,
        num_waves: int = 4,
        varlen_q: bool = False,
        varlen_k: bool = False,
        has_seqused_q: bool = False,
        has_seqused_k: bool = False,
        score_mod=None,
        mask_mod=None,
        num_aux_tensors: int = 0,
        has_learnable_sink: bool = False,
        block_sparse: bool = False,
        has_full_blocks: bool = False,
        sparse_block_size: tuple | None = None,
        paged_kv: bool = False,
    ):
        if dtype not in ("bf16", "fp16"):
            raise ValueError(f"dtype must be bf16 or fp16, got {dtype}")
        head_dim_v = head_dim if head_dim_v is None else head_dim_v
        if head_dim % K_STEP or head_dim_v % MFMA_M:
            raise ValueError(f"need head_dim % {K_STEP} == 0 and head_dim_v % {MFMA_M} == 0")
        if tile_n % MFMA_M:
            raise ValueError(f"tile_n must be a multiple of {MFMA_M}")
        if is_causal and is_local:
            raise ValueError("pass causal with a left window as is_local with window_right = 0")
        if not 0 <= num_aux_tensors <= MAX_AUX_TENSORS:
            raise ValueError(f"at most {MAX_AUX_TENSORS} aux tensors, got {num_aux_tensors}")
        self.score_mod = score_mod
        self.mask_mod = mask_mod
        self.num_aux_tensors = num_aux_tensors
        self.has_learnable_sink = has_learnable_sink
        self.dtype = dtype
        self.head_dim = head_dim
        self.head_dim_v = head_dim_v
        self.qhead_per_kvhead = qhead_per_kvhead
        self.is_causal = is_causal
        self.is_local = is_local
        self.tile_n = tile_n
        self.num_waves = num_waves
        self.varlen_q = varlen_q
        self.varlen_k = varlen_k
        self.has_seqused_q = has_seqused_q
        self.has_seqused_k = has_seqused_k
        self.tile_m = MFMA_M * num_waves
        self.num_threads = 64 * num_waves
        if block_sparse and (varlen_q or varlen_k):
            raise NotImplementedError("block sparsity with varlen is not supported yet")
        if paged_kv and varlen_k:
            raise ValueError("page_table is not supported with cu_seqlens_k (as in FA4)")
        self.paged_kv = paged_kv
        self.block_sparse = block_sparse
        self.has_full_blocks = block_sparse and has_full_blocks
        self.sparse_block_size = sparse_block_size
        self.q_subtile, self.kv_subtile = subtile_factors(sparse_block_size, self.tile_m, tile_n)
        for d in (head_dim, head_dim_v):
            if (tile_n * d // 8) % self.num_threads:
                raise ValueError(f"KV tile {tile_n}x{d} does not split evenly over {self.num_threads} threads")
        self.launcher = self._build()

    def _build(self):
        D, DV, TN = self.head_dim, self.head_dim_v, self.tile_n
        NT, TM = self.num_threads, self.tile_m
        Q_PER_KV = self.qhead_per_kvhead
        elem = fx.BFloat16 if self.dtype == "bf16" else fx.Float16
        k_iters = TN * D // 8 // NT
        v_iters = TN * DV // 8 // NT
        block_info = BlockInfo(TM, TN, self.is_causal, self.is_local)
        is_causal, is_local = self.is_causal, self.is_local
        varlen_q, varlen_k = self.varlen_q, self.varlen_k
        has_seqused_q, has_seqused_k = self.has_seqused_q, self.has_seqused_k
        score_mod, mask_mod = self.score_mod, self.mask_mod
        num_aux, has_sink = self.num_aux_tensors, self.has_learnable_sink
        block_sparse, has_full_blocks = self.block_sparse, self.has_full_blocks
        Q_SUB, KV_SUB = self.q_subtile, self.kv_subtile
        paged_kv = self.paged_kv

        @fx.struct
        class SharedStorage:
            k: fx.Array[elem, TN * D, 16]
            v: fx.Array[elem, TN * DV, 16]

        @flyc.kernel(known_block_size=[NT, 1, 1])
        def kernel(
            Q: fx.Tensor,
            K: fx.Tensor,
            V: fx.Tensor,
            O: fx.Tensor,  # noqa: E741
            LSE: fx.Tensor,
            CuSeqlensQ: fx.Tensor,
            CuSeqlensK: fx.Tensor,
            SeqUsedQ: fx.Tensor,
            SeqUsedK: fx.Tensor,
            Aux0: fx.Tensor,
            Aux1: fx.Tensor,
            Aux2: fx.Tensor,
            Aux3: fx.Tensor,
            Sink: fx.Tensor,
            MaskCnt: fx.Tensor,
            MaskIdx: fx.Tensor,
            FullCnt: fx.Tensor,
            FullIdx: fx.Tensor,
            PageTable: fx.Tensor,
            page_size: fx.Int32,
            seqlen_q_static: fx.Int32,
            seqlen_k_static: fx.Int32,
            softmax_scale: fx.Float32,
            window_left: fx.Int32,
            window_right: fx.Int32,
        ):
            tid = fx.thread_idx.x
            lane = tid % fx.Int32(64)
            wave = tid // fx.Int32(64)
            m_block = fx.Int32(fx.block_idx.x)
            head = fx.Int32(fx.block_idx.y)
            batch = fx.Int32(fx.block_idx.z)
            kv_head = head // fx.Int32(Q_PER_KV)

            mma_atom = fx.make_mma_atom(fx.rocdl.MFMA(MFMA_M, MFMA_M, K_STEP, elem))
            tiled_mma = fx.make_tiled_mma(mma_atom, fx.make_layout((1, 1, 1), (1, 1, 1)))
            thr_mma = tiled_mma.get_slice(lane)
            # Coordinate views: an element's value is its own (row, col) index.
            b_coords = thr_mma.partition_B(fx.make_view(0, fx.make_layout((MFMA_M, K_STEP), (1, MFMA_M))))
            c_rows = thr_mma.partition_C(fx.make_view(0, fx.make_layout((MFMA_M, MFMA_M), (1, 0))))
            c_cols = thr_mma.partition_C(fx.make_view(0, fx.make_layout((MFMA_M, MFMA_M), (0, 1))))

            def mfma(a_frag, b_frag, acc):
                c_frag = fx.make_fragment_like(c_rows, fx.Float32)
                c_frag.store(Vec(acc))
                fx.gemm(tiled_mma, c_frag, a_frag, b_frag, c_frag)
                return c_frag.load()

            copy_g128 = fx.make_copy_atom(fx.rocdl.BufferCopy128b(), elem)
            copy_g64 = fx.make_copy_atom(fx.rocdl.BufferCopy64b(), elem)
            copy_s128 = fx.make_copy_atom(fx.UniversalCopy128b(), elem)
            copy_s64 = fx.make_copy_atom(fx.UniversalCopy64b(), elem)
            copy_s16 = fx.make_copy_atom(fx.UniversalCopy16b(), elem)
            copy_k = fx.make_tiled_copy_A(copy_s64, tiled_mma).get_slice(lane)
            copy_vt = fx.make_tiled_copy_A(copy_s16, tiled_mma).get_slice(lane)

            q_t = fx.rocdl.make_buffer_tensor(Q)
            k_t = fx.rocdl.make_buffer_tensor(K)
            v_t = fx.rocdl.make_buffer_tensor(V)
            o_t = fx.rocdl.make_buffer_tensor(O)
            lse_t = fx.rocdl.make_buffer_tensor(LSE)

            lds = fx.SharedAllocator().allocate(SharedStorage).peek()
            k_lds_tiles = fx.flat_divide(fx.make_view(lds.k.ptr, fx.make_layout((TN, D), (D, 1))), (MFMA_M, K_STEP))
            k_lds_packs = fx.logical_divide(fx.make_view(lds.k.ptr, fx.make_layout(TN * D, 1)), fx.make_layout(8, 1))
            # V^T view of the row-major [TN, DV] V tile: (d, key) with strides (1, DV).
            vt_lds_tiles = fx.flat_divide(fx.make_view(lds.v.ptr, fx.make_layout((DV, TN), (1, DV))), (MFMA_M, K_STEP))
            v_lds_packs = fx.logical_divide(fx.make_view(lds.v.ptr, fx.make_layout(TN * DV, 1)), fx.make_layout(8, 1))

            seqlen = SeqlenInfo.create(
                batch,
                seqlen_q_static,
                seqlen_k_static,
                cu_seqlens_q=fx.rocdl.make_buffer_tensor(CuSeqlensQ) if varlen_q else None,
                cu_seqlens_k=fx.rocdl.make_buffer_tensor(CuSeqlensK) if varlen_k else None,
                seqused_q=fx.rocdl.make_buffer_tensor(SeqUsedQ) if has_seqused_q else None,
                seqused_k=fx.rocdl.make_buffer_tensor(SeqUsedK) if has_seqused_k else None,
            )
            aux_tensors = tuple(fx.rocdl.make_buffer_tensor(t) for t in (Aux0, Aux1, Aux2, Aux3)[:num_aux])
            mask = AttentionMask(
                seqlen, is_causal, is_local, window_left, window_right, mask_mod, batch, head, aux_tensors
            )

            # Helpers defined in the kernel body are AST-rewritten along with it: an
            # ``if`` becomes branch closures, so a ``return`` inside one would only leave
            # the branch. Choose with conditional expressions and return once.
            def q_side_row(t, pos, h):
                """Row ``pos`` of this sequence in a query-side tensor (q or out)."""
                coord = (seqlen.offset_q + pos, h, None) if varlen_q else (batch, pos, h, None)
                return fx.slice(t, coord)

            pages = fx.slice(fx.rocdl.make_buffer_tensor(PageTable), (batch, None)) if paged_kv else None

            def kv_side_row(t, pos):
                coord = (
                    (fx.Int32(pages[pos // page_size]), pos % page_size, kv_head, None) if paged_kv
                    else (seqlen.offset_k + pos, kv_head, None) if varlen_k
                    else (batch, pos, kv_head, None)
                )
                return fx.slice(t, coord)

            def stage_kv(kv_base):
                """Copy the K and V tiles at ``kv_base`` to LDS (rows clamped to the sequence)."""
                last_key = seqlen.seqlen_k - fx.Int32(1)
                for it in range_constexpr(k_iters):
                    linear = fx.Int32(it * NT) + tid
                    key = _min(kv_base + linear // fx.Int32(D // 8), last_key)
                    src = fx.logical_divide(kv_side_row(k_t, key), fx.make_layout(8, 1))
                    reg = fx.make_rmem_tensor(8, elem)
                    fx.copy(copy_g128, fx.slice(src, (None, linear % fx.Int32(D // 8))), reg)
                    fx.copy(copy_s128, reg, fx.slice(k_lds_packs, (None, linear)))
                for it in range_constexpr(v_iters):
                    linear = fx.Int32(it * NT) + tid
                    key = _min(kv_base + linear // fx.Int32(DV // 8), last_key)
                    src = fx.logical_divide(kv_side_row(v_t, key), fx.make_layout(8, 1))
                    reg = fx.make_rmem_tensor(8, elem)
                    fx.copy(copy_g128, fx.slice(src, (None, linear % fx.Int32(DV // 8))), reg)
                    fx.copy(copy_s128, reg, fx.slice(v_lds_packs, (None, linear)))

            def sparse_n_block(idx_row, j):
                """Kernel tile of the ``j``-th entry of a block list, sparse blocks split in KV_SUB."""
                return fx.Int32(idx_row[j // fx.Int32(KV_SUB)]) * fx.Int32(KV_SUB) + j % fx.Int32(KV_SUB)

            def compute_one_n_block(n_block, q_frags, q_pos, row_max, row_sum, o_acc, apply_mask_mod=True):
                kv_base = n_block * fx.Int32(TN)
                fx.gpu.barrier()  # every wave is done reading the previous tile
                stage_kv(kv_base)
                fx.gpu.barrier()

                zero16 = Vec.filled(16, 0.0, fx.Float32)
                scores, keep = [], []
                for half in range_constexpr(TN // MFMA_M):
                    acc = zero16
                    for ks in range_constexpr(D // K_STEP):
                        tile = fx.slice(k_lds_tiles, (None, None, half, ks))
                        a_frag = thr_mma.make_fragment_A(tile)
                        fx.copy(copy_s64, copy_k.partition_S(tile), copy_k.retile(a_frag))
                        acc = mfma(a_frag, q_frags[ks], acc)
                    acc = Vec(acc)
                    for j in range_constexpr(16):
                        kv_pos = kv_base + fx.Int32(half * MFMA_M) + fx.Int32(fx.get_scalar(c_rows[j]))
                        score = _apply_score_mod(score_mod, acc[j] * softmax_scale, batch, head, q_pos, kv_pos, mask)
                        scores.append(score * fx.Float32(LOG2E))
                        keep.append(mask.keep(q_pos, kv_pos, apply_mask_mod=apply_mask_mod))

                probs, new_max, new_sum, rescale = Softmax.online_softmax(row_max, row_sum, scores, keep)
                rescale_vec = Vec.from_elements([rescale], fx.Float32).broadcast_to(16)
                o_acc = [Vec(o) * rescale_vec for o in o_acc]
                for half in range_constexpr(TN // MFMA_M):
                    for g in range_constexpr(MFMA_M // K_STEP):
                        first = half * 16 + 4 * g
                        p_frag = fx.make_fragment_like(b_coords, elem)
                        p_frag.store(Vec.from_elements(probs[first : first + 4], fx.Float32).to(elem))
                        for c in range_constexpr(DV // MFMA_M):
                            tile = fx.slice(vt_lds_tiles, (None, None, c, half * (MFMA_M // K_STEP) + g))
                            a_frag = thr_mma.make_fragment_A(tile)
                            fx.copy(copy_s16, copy_vt.partition_S(tile), copy_vt.retile(a_frag))
                            o_acc[c] = mfma(a_frag, p_frag, o_acc[c])
                return new_max, new_sum, o_acc

            # A varlen grid is sized for the longest sequence; shorter ones skip the
            # excess query blocks. The condition is uniform over the CTA, so the
            # barriers inside stay convergent.
            if m_block * fx.Int32(TM) < seqlen.seqlen_q:
                n_block_min, n_block_max = block_info.get_n_block_min_max(seqlen, m_block, window_left, window_right)
                q_pos = m_block * fx.Int32(TM) + wave * fx.Int32(MFMA_M) + fx.Int32(fx.get_scalar(c_cols[0]))
                q_row = _min(q_pos, seqlen.seqlen_q - fx.Int32(1))

                # ---- Q: B fragments for every reduction step, register-resident ----
                q_k0 = fx.Int32(fx.get_scalar(b_coords[0])) // fx.Int32(MFMA_M)  # this lane's first k in a step
                q_packs = fx.logical_divide(q_side_row(q_t, q_row, head), fx.make_layout(4, 1))
                q_frags = []
                for ks in range_constexpr(D // K_STEP):
                    reg = fx.make_rmem_tensor(4, elem)
                    fx.copy(copy_g64, fx.slice(q_packs, (None, (fx.Int32(ks * K_STEP) + q_k0) // fx.Int32(4))), reg)
                    frag = fx.make_fragment_like(b_coords, elem)
                    frag.store(Vec(reg.load()))
                    q_frags.append(frag)

                init = Softmax.initial_state() + [Vec.filled(16, 0.0, fx.Float32) for _ in range_constexpr(DV // MFMA_M)]
                results = init
                if block_sparse:
                    # FA4's lists: blocks needing mask_mod, then fully kept blocks without it.
                    # A sparse KV block spans KV_SUB kernel tiles, a sparse Q block Q_SUB m_blocks.
                    sparse_m = m_block // fx.Int32(Q_SUB)
                    mask_cnt = fx.Int32(fx.slice(fx.rocdl.make_buffer_tensor(MaskCnt), (batch, head, None))[sparse_m])
                    mask_idx = fx.slice(fx.rocdl.make_buffer_tensor(MaskIdx), (batch, head, sparse_m, None))
                    for n_iter, state in range(fx.Int32(0), mask_cnt * fx.Int32(KV_SUB), fx.Int32(1), init=results):
                        o_state = [state[2 + c] for c in range_constexpr(DV // MFMA_M)]
                        row_max, row_sum, o_acc = compute_one_n_block(
                            sparse_n_block(mask_idx, fx.Int32(n_iter)), q_frags, q_pos, state[0], state[1], o_state
                        )
                        results = yield [row_max, row_sum] + o_acc
                    if has_full_blocks:
                        full_cnt = fx.Int32(fx.slice(fx.rocdl.make_buffer_tensor(FullCnt), (batch, head, None))[sparse_m])
                        full_idx = fx.slice(fx.rocdl.make_buffer_tensor(FullIdx), (batch, head, sparse_m, None))
                        for n_iter, state in range(fx.Int32(0), full_cnt * fx.Int32(KV_SUB), fx.Int32(1), init=results):
                            o_state = [state[2 + c] for c in range_constexpr(DV // MFMA_M)]
                            row_max, row_sum, o_acc = compute_one_n_block(
                                sparse_n_block(full_idx, fx.Int32(n_iter)), q_frags, q_pos, state[0], state[1], o_state,
                                apply_mask_mod=False,
                            )
                            results = yield [row_max, row_sum] + o_acc
                else:
                    for n_iter, state in range(n_block_min, n_block_max, fx.Int32(1), init=init):
                        o_state = [state[2 + c] for c in range_constexpr(DV // MFMA_M)]
                        row_max, row_sum, o_acc = compute_one_n_block(
                            fx.Int32(n_iter), q_frags, q_pos, state[0], state[1], o_state
                        )
                        results = yield [row_max, row_sum] + o_acc

                # ---- Epilogue: normalize, store O (4 contiguous elements per group) and LSE ----
                inv_sum, lse = Softmax.finalize(
                    fx.Float32(results[0]), fx.Float32(results[1]), _sink_log2(has_sink, Sink, head)
                )
                inv_vec = Vec.from_elements([inv_sum], fx.Float32).broadcast_to(16)
                if q_pos < seqlen.seqlen_q:
                    o_packs = fx.logical_divide(q_side_row(o_t, q_row, head), fx.make_layout(4, 1))
                    for c in range_constexpr(DV // MFMA_M):
                        o = Vec(results[2 + c]) * inv_vec
                        for g in range_constexpr(4):
                            d_start = fx.Int32(c * MFMA_M) + fx.Int32(fx.get_scalar(c_rows[4 * g]))
                            reg = fx.make_rmem_tensor(4, elem)
                            reg.store(Vec.from_elements([o[4 * g + i] for i in range_constexpr(4)], fx.Float32).to(elem))
                            fx.copy(copy_g64, reg, fx.slice(o_packs, (None, d_start // fx.Int32(4))))
                    if lane < fx.Int32(MFMA_M):
                        if varlen_q:
                            lse_row = fx.slice(lse_t, (head, None))
                            lse_row[seqlen.offset_q + q_row] = lse
                        else:
                            lse_row = fx.slice(lse_t, (batch, head, None))
                            lse_row[q_row] = lse

        @flyc.jit
        def launch(
            Q: fx.Tensor,
            K: fx.Tensor,
            V: fx.Tensor,
            O: fx.Tensor,  # noqa: E741
            LSE: fx.Tensor,
            CuSeqlensQ: fx.Tensor,
            CuSeqlensK: fx.Tensor,
            SeqUsedQ: fx.Tensor,
            SeqUsedK: fx.Tensor,
            Aux0: fx.Tensor,
            Aux1: fx.Tensor,
            Aux2: fx.Tensor,
            Aux3: fx.Tensor,
            Sink: fx.Tensor,
            MaskCnt: fx.Tensor,
            MaskIdx: fx.Tensor,
            FullCnt: fx.Tensor,
            FullIdx: fx.Tensor,
            PageTable: fx.Tensor,
            page_size: fx.Int32,
            seqlen_q_static: fx.Int32,
            seqlen_k_static: fx.Int32,
            num_m_blocks: fx.Int32,
            num_heads: fx.Int32,
            batch: fx.Int32,
            softmax_scale: fx.Float32,
            window_left: fx.Int32,
            window_right: fx.Int32,
            stream: fx.Stream = fx.Stream(None),
        ):
            kernel(
                Q, K, V, O, LSE, CuSeqlensQ, CuSeqlensK, SeqUsedQ, SeqUsedK,
                Aux0, Aux1, Aux2, Aux3, Sink, MaskCnt, MaskIdx, FullCnt, FullIdx, PageTable, page_size,
                seqlen_q_static, seqlen_k_static, softmax_scale, window_left, window_right,
            ).launch(grid=(num_m_blocks, num_heads, batch), block=(NT, 1, 1), stream=stream)

        return launch

    def __call__(
        self,
        q,
        k,
        v,
        softmax_scale,
        out=None,
        lse=None,
        window_left=-1,
        window_right=-1,
        cu_seqlens_q=None,
        cu_seqlens_k=None,
        seqused_q=None,
        seqused_k=None,
        max_seqlen_q=None,
        aux_tensors=(),
        learnable_sink=None,
        block_sparse_tensors=None,
        page_table=None,
        stream=None,
    ):
        """Run the kernel; returns ``(out, lse)``. Varlen inputs need ``max_seqlen_q`` to
        size the grid. Absent optional tensors are passed as unused placeholders.

        Paged KV (FA4): k / v are ``[num_pages, page_size, Hk, D]`` and ``page_table``
        ``[B, max_pages]`` int32; sequence lengths come from ``seqused_k``, else
        ``max_pages * page_size``."""
        import torch

        if (page_table is not None) != self.paged_kv:
            raise ValueError("page_table does not match how this kernel was built")
        if (cu_seqlens_q is not None) != self.varlen_q or (cu_seqlens_k is not None) != self.varlen_k:
            raise ValueError("cu_seqlens_q / cu_seqlens_k do not match how this kernel was built")
        if (seqused_q is not None) != self.has_seqused_q or (seqused_k is not None) != self.has_seqused_k:
            raise ValueError("seqused_q / seqused_k do not match how this kernel was built")
        aux_tensors = tuple(aux_tensors or ())
        if len(aux_tensors) != self.num_aux_tensors:
            raise ValueError(f"kernel built for {self.num_aux_tensors} aux tensors, got {len(aux_tensors)}")
        if (learnable_sink is not None) != self.has_learnable_sink:
            raise ValueError("learnable_sink does not match how this kernel was built")
        if (block_sparse_tensors is not None) != self.block_sparse:
            raise ValueError("block_sparse_tensors does not match how this kernel was built")
        if self.block_sparse:
            if (block_sparse_tensors.full_block_cnt is not None) != self.has_full_blocks:
                raise ValueError("full_block_cnt / full_block_idx do not match how this kernel was built")
            if subtile_factors(block_sparse_tensors.block_size, self.tile_m, self.tile_n) != (
                self.q_subtile, self.kv_subtile,
            ):
                raise ValueError("block_sparse_tensors.block_size does not match how this kernel was built")
        if self.varlen_q:
            total_q, num_heads, _ = q.shape
            batch = cu_seqlens_q.numel() - 1
            seqlen_q = int(max_seqlen_q)
            out_shape, lse_shape = (total_q, num_heads, self.head_dim_v), (num_heads, total_q)
        else:
            batch, seqlen_q, num_heads, _ = q.shape
            out_shape, lse_shape = (batch, seqlen_q, num_heads, self.head_dim_v), (batch, num_heads, seqlen_q)
        seqlen_k = 0 if self.varlen_k else k.shape[1]
        page_size = 1
        if self.paged_kv:
            if page_table.dtype != torch.int32 or page_table.shape[0] != batch:
                raise ValueError("page_table must be int32 [batch, max_pages]")
            page_size = k.shape[1]
            seqlen_k = page_table.shape[1] * page_size
        if out is None:
            out = torch.empty(out_shape, dtype=q.dtype, device=q.device)
        if lse is None:
            lse = torch.empty(lse_shape, dtype=torch.float32, device=q.device)
        placeholder = lse
        if learnable_sink is not None:
            learnable_sink = learnable_sink.to(torch.float32).contiguous()
        aux_slots = aux_tensors + (placeholder,) * (MAX_AUX_TENSORS - len(aux_tensors))
        sparse_slots = (placeholder,) * 4
        if self.block_sparse:
            bst = broadcast_heads(block_sparse_tensors, num_heads)
            sparse_slots = tuple(
                t if t is not None else placeholder
                for t in (bst.mask_block_cnt, bst.mask_block_idx, bst.full_block_cnt, bst.full_block_idx)
            )
        num_m_blocks = max((seqlen_q + self.tile_m - 1) // self.tile_m, 1)
        stream = torch.cuda.current_stream() if stream is None else stream
        self.launcher(
            q, k, v, out, lse,
            cu_seqlens_q if cu_seqlens_q is not None else placeholder,
            cu_seqlens_k if cu_seqlens_k is not None else placeholder,
            seqused_q if seqused_q is not None else placeholder,
            seqused_k if seqused_k is not None else placeholder,
            *aux_slots,
            learnable_sink if learnable_sink is not None else placeholder,
            *sparse_slots,
            page_table if page_table is not None else placeholder, page_size,
            seqlen_q, seqlen_k, num_m_blocks, num_heads, batch,
            float(softmax_scale), int(window_left), int(window_right),
            stream=stream,
        )
        return out, lse
