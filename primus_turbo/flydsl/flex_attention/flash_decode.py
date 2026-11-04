###############################################################################
# Copyright (c) 2026, Advanced Micro Devices, Inc. All rights reserved.
#
# See LICENSE for license information.
###############################################################################

"""Paged-KV decode attention in FlyDSL, after aiter's ``paged_attention_ragged``
(vLLM's ``paged_attention_ll4mi_QKV_mfma16`` kernel), on FA4's paged layout.

One query token per sequence. A CTA owns one (sequence, 256-token partition, KV head):
all ``G`` query heads of the KV head share it, so each KV page is read once (GQA
packing), and partitions keep the GPU full at any batch size. Four waves take 64 of
the partition's tokens each, as four 16-token chunks.

Per chunk, ``S = K . Q^T`` with MFMA 16x16x16: tokens are the rows, the group's query
heads the columns. Lane ``l`` holds head ``l % 16`` and tokens ``4 * (l // 16) + i``;
K goes from global memory straight into registers, 16 bytes per lane, all loads issued
before any math. That register layout is also the A operand of ``O = P . V``, so the
probabilities never move. V is staged per wave in LDS and read transposed. The
partition max / sum per head reduce in-lane, across 16-lane groups by shuffle and
across waves in LDS; each wave's partial O is summed in LDS. A partition writes its
normalized O and log2-domain LSE; ``_build_reduce`` merges the partitions.

Tensors: q ``[B, Hq, D]``, k / v caches ``[num_pages, page_size, Hk, D]``,
``page_table [B, max_pages]`` int32, ``seqused_k [B]`` int32. Output ``[B, Hq, D]`` and
lse ``[B, Hq]`` (natural log; -inf for an empty sequence).

Flex features match ``FlashAttentionForward`` (FA4 conventions): ``score_mod`` /
``mask_mod`` with up to 4 aux tensors, a sliding window (``is_local``, runtime
``window_left``; partitions wholly outside it are skipped) and a learnable sink (folded
into the reduce). The single query is ``q_idx = 0`` with the keys bottom-right aligned
to it, and ``seqlen_info.offset_q`` is the sequence's row in ``q``, so aux tensors can
be indexed per query token.
"""

import flydsl.compiler as flyc
import flydsl.expr as fx
from flydsl.compiler.protocol import dsl_size_of
from flydsl.expr import range_constexpr
from flydsl.expr.typing import T
from flydsl.expr.typing import Vector as Vec

from primus_turbo.flydsl.flex_attention.flash_fwd import MAX_AUX_TENSORS, _apply_score_mod
from primus_turbo.flydsl.flex_attention.mask import AttentionMask
from primus_turbo.flydsl.flex_attention.seqlen_info import SeqlenInfo
from primus_turbo.flydsl.flex_attention.softmax import LN2, LOG2E, NEG_BIG

PARTITION = 256  # tokens per CTA
NWAVES = 4
TOK_PER_WAVE = PARTITION // NWAVES  # 64
CHUNK = 16  # tokens per MFMA
NCHUNK = TOK_PER_WAVE // CHUNK  # 4
MAX_GROUP = 16  # query heads per KV head that fit the MFMA's 16 columns


def _min(a, b):
    return (a < b).select(a, b)


def _max(a, b):
    return (a > b).select(a, b)


def _first_live_partition(is_local, seqlen, window_left):
    """First partition holding a key the window keeps (0 without a window)."""
    if not is_local:
        return fx.Int32(0)
    first_key = _max(seqlen - fx.Int32(1) - window_left, fx.Int32(0))
    return (window_left >= fx.Int32(0)).select(first_key // fx.Int32(PARTITION), fx.Int32(0))


def _finish(m, wsum, sink_log2):
    """``(output scale, lse)`` from the merged partitions: ``acc * scale`` is the output
    when ``acc = sum_p 2^(lse_p - m) out_p`` and ``wsum = sum_p 2^(lse_p - m)``. A sink adds
    one value-less term to the denominator. No kept key: O = 0 and LSE = -inf (or the
    sink)."""
    if sink_log2 is None:
        has = wsum > fx.Float32(0.0)
        scale = has.select(fx.Float32(1.0) / wsum, fx.Float32(0.0))
        return scale, has.select((m + fx.math.log2(wsum)) * fx.Float32(LN2), fx.Float32(float("-inf")))
    new_m = _max(m, sink_log2)
    rescale = fx.math.exp2(m - new_m)
    total = wsum * rescale + fx.math.exp2(sink_log2 - new_m)
    return rescale / total, (new_m + fx.math.log2(total)) * fx.Float32(LN2)


def _sink_log2(has_sink, sink, head):
    if not has_sink:
        return None
    return fx.Float32(fx.rocdl.make_buffer_tensor(sink)[head]) * fx.Float32(LOG2E)


class FlashAttentionDecode:
    """Builds the decode and reduce launchers for one compile-time configuration."""

    def __init__(
        self,
        dtype: str = "bf16",
        head_dim: int = 128,
        qhead_per_kvhead: int = 1,
        is_local: bool = False,
        score_mod=None,
        mask_mod=None,
        num_aux_tensors: int = 0,
        has_learnable_sink: bool = False,
    ):
        if dtype not in ("bf16", "fp16"):
            raise ValueError(f"dtype must be bf16 or fp16, got {dtype}")
        if head_dim % 32:
            raise ValueError("head_dim must be a multiple of 32")
        if not 1 <= qhead_per_kvhead <= MAX_GROUP:
            raise ValueError(f"at most {MAX_GROUP} query heads per KV head, got {qhead_per_kvhead}")
        if not 0 <= num_aux_tensors <= MAX_AUX_TENSORS:
            raise ValueError(f"at most {MAX_AUX_TENSORS} aux tensors, got {num_aux_tensors}")
        self.dtype, self.head_dim, self.group = dtype, head_dim, qhead_per_kvhead
        self.is_local, self.score_mod, self.mask_mod = is_local, score_mod, mask_mod
        self.num_aux_tensors, self.has_learnable_sink = num_aux_tensors, has_learnable_sink
        self.decode_launcher = self._build_decode()
        self.reduce_launcher = self._build_reduce()

    # ------------------------------------------------------------- decode ----
    def _build_decode(self):
        D, G = self.head_dim, self.group
        fp16 = self.dtype == "fp16"
        elem = fx.Float16 if fp16 else fx.BFloat16
        is_local, score_mod, mask_mod = self.is_local, self.score_mod, self.mask_mod
        num_aux = self.num_aux_tensors
        NT = NWAVES * 64
        V_ROW = D + 8  # padded LDS row (elements) for the staged V chunk
        V_CHUNK_BYTES = CHUNK * V_ROW * 2
        # LDS: per-wave V chunk | cross-wave max / sum | per-head final max / sum | partial O
        off_v = 0
        off_max = off_v + NWAVES * V_CHUNK_BYTES
        off_sum = off_max + NWAVES * 16 * 4
        off_o = off_sum + NWAVES * 16 * 4
        total = off_o + NWAVES * 16 * D * 4

        @fx.struct
        class SharedStorage:
            buf: fx.Array[fx.Int32, total // 4, 16]

        def mfma(a, b, acc):
            if fp16:
                return fx.rocdl.mfma_f32_16x16x16f16(T.f32x4, [a, b, acc, 0, 0, 0])
            return fx.rocdl.mfma_f32_16x16x16bf16_1k(
                T.f32x4, [Vec(a).bitcast(fx.Int16), Vec(b).bitcast(fx.Int16), acc, 0, 0, 0]
            )

        def as4(values):
            return Vec.from_elements(values, elem)

        @flyc.kernel(known_block_size=[NT, 1, 1])
        def kernel(
            Q: fx.Tensor, K: fx.Tensor, V: fx.Tensor, PageTable: fx.Tensor, SeqUsedK: fx.Tensor,
            POut: fx.Tensor, PLse: fx.Tensor,
            Aux0: fx.Tensor, Aux1: fx.Tensor, Aux2: fx.Tensor, Aux3: fx.Tensor,
            page_size: fx.Int32, softmax_scale: fx.Float32, window_left: fx.Int32,
        ):
            tid = fx.Int32(fx.thread_idx.x)
            lane = tid % fx.Int32(64)
            wave = tid // fx.Int32(64)
            l16 = lane % fx.Int32(16)
            r = lane // fx.Int32(16)
            b = fx.Int32(fx.block_idx.x)
            part = fx.Int32(fx.block_idx.y)
            kvh = fx.Int32(fx.block_idx.z)

            q_t = fx.rocdl.make_buffer_tensor(Q)
            k_t = fx.rocdl.make_buffer_tensor(K)
            v_t = fx.rocdl.make_buffer_tensor(V)
            pages = fx.slice(fx.rocdl.make_buffer_tensor(PageTable), (b, None))
            seqlen = fx.Int32(fx.rocdl.make_buffer_tensor(SeqUsedK)[b])
            pout_t = fx.rocdl.make_buffer_tensor(POut)
            plse_t = fx.rocdl.make_buffer_tensor(PLse)
            copy_g128 = fx.make_copy_atom(fx.rocdl.BufferCopy128b(), elem)
            copy_f128 = fx.make_copy_atom(fx.rocdl.BufferCopy128b(), fx.Float32)

            lds = fx.SharedAllocator().allocate(SharedStorage).peek()
            lds_base = fx.recast_iter(fx.Uint8, lds.buf.ptr)

            def lds_ptr(byte_off, ty):
                p = fx.add_offset(lds_base, fx.make_int_tuple(byte_off))
                return fx.recast_iter(fx.PointerType.get(ty.ir_type, fx.AddressSpace.Shared, dsl_size_of(ty)), p)

            def lds_store(byte_off, ty, vec):
                fx.ptr_store(vec, lds_ptr(byte_off, ty))

            def lds_load(byte_off, ty, n):
                return Vec(fx.ptr_load(lds_ptr(byte_off, ty), result_type=Vec.make_type(n, ty)))

            def load8(row, first):
                """8 contiguous elements of a global row, starting at element ``first``."""
                packs = fx.logical_divide(row, fx.make_layout(8, 1))
                reg = fx.make_rmem_tensor(8, elem)
                fx.copy(copy_g128, fx.slice(packs, (None, first // fx.Int32(8))), reg)
                return Vec(reg.load())

            def kv_row(t, tok):
                page = fx.Int32(pages[tok // page_size])
                return fx.slice(t, (page, tok % page_size, kvh, None))

            part_start = part * fx.Int32(PARTITION)
            # Q: B operand, column = head l16 (clamped into the group; extra columns compute
            # garbage that is never stored).
            head = kvh * fx.Int32(G) + _min(l16, fx.Int32(G - 1))
            seqlen_info = SeqlenInfo(b, fx.Int32(0), fx.Int32(1), seqlen)
            aux_tensors = tuple(fx.rocdl.make_buffer_tensor(t) for t in (Aux0, Aux1, Aux2, Aux3)[:num_aux])
            mask = AttentionMask(seqlen_info, False, is_local, window_left, fx.Int32(-1), mask_mod, b, head,
                                 aux_tensors)
            q_idx = fx.Int32(0)
            # The rewriter carries a kernel local whose method is called inside a runtime
            # ``if`` as branch state, so the call goes through a plain name.
            mask_keep = mask.keep
            # Partitions past the sequence or before the window do nothing; the reducer
            # never reads them.
            live = (part_start < seqlen) & (part >= _first_live_partition(is_local, seqlen, window_left))
            if live:
                last = seqlen - fx.Int32(1)
                wave_start = part_start + wave * fx.Int32(TOK_PER_WAVE)

                # Each lane owns d = 8r + 32p .. +8 of Q and K.
                q_row = fx.slice(q_t, (b, head, None))
                q8 = [load8(q_row, r * fx.Int32(8) + fx.Int32(32 * p)) for p in range_constexpr(D // 32)]

                # K for all four chunks, straight to registers (A operand, row = token l16).
                k8 = []
                for c in range_constexpr(NCHUNK):
                    tok = _min(wave_start + fx.Int32(c * CHUNK) + l16, last)
                    row = kv_row(k_t, tok)
                    k8.append([load8(row, r * fx.Int32(8) + fx.Int32(32 * p)) for p in range_constexpr(D // 32)])

                # V for all four chunks: lane j of the wave holds pack j (+64, ...) of the
                # chunk's 16 x D tile, row = j // (D / 8), 8 elements at column 8 * (j % (D / 8)).
                PACKS = CHUNK * D // 8
                v8 = []
                for c in range_constexpr(NCHUNK):
                    chunk = []
                    for it in range_constexpr(PACKS // 64):
                        j = fx.Int32(it * 64) + lane
                        tok = _min(wave_start + fx.Int32(c * CHUNK) + j // fx.Int32(D // 8), last)
                        chunk.append(load8(kv_row(v_t, tok), fx.Int32(8) * (j % fx.Int32(D // 8))))
                    v8.append(chunk)

                # S = K . Q^T: lane holds head l16, tokens 4r + i of each chunk.
                scores, keep = [], []
                for c in range_constexpr(NCHUNK):
                    acc = Vec.filled(4, 0.0, fx.Float32)
                    for p in range_constexpr(D // 32):
                        acc = mfma(as4([k8[c][p][i] for i in range(4)]), as4([q8[p][i] for i in range(4)]), acc)
                        acc = mfma(as4([k8[c][p][i] for i in range(4, 8)]), as4([q8[p][i] for i in range(4, 8)]), acc)
                    acc = Vec(acc)
                    for i in range_constexpr(4):
                        tok = wave_start + fx.Int32(c * CHUNK) + r * fx.Int32(4) + fx.Int32(i)
                        score = _apply_score_mod(score_mod, acc[i] * softmax_scale, b, head, q_idx, tok, mask)
                        scores.append(score * fx.Float32(LOG2E))
                        keep.append(mask_keep(q_idx, tok))

                # Partition max per head: in-lane, across the four 16-lane groups, across waves.
                m = fx.Float32(NEG_BIG)
                for s, k in zip(scores, keep):
                    m = _max(m, k.select(s, fx.Float32(NEG_BIG)))
                m = _max(m, fx.Float32(fx.gpu.shuffle_xor(m, 16, 64)))
                m = _max(m, fx.Float32(fx.gpu.shuffle_xor(m, 32, 64)))
                lds_store(fx.Int32(off_max) + (wave * fx.Int32(16) + l16) * fx.Int32(4), fx.Float32,
                          Vec.from_elements([m], fx.Float32))
                fx.gpu.barrier()
                m = fx.Float32(NEG_BIG)
                for w in range_constexpr(NWAVES):
                    m = _max(m, lds_load(fx.Int32(off_max + w * 64) + l16 * fx.Int32(4), fx.Float32, 1)[0])

                probs = [k.select(fx.math.exp2(s - m), fx.Float32(0.0)) for s, k in zip(scores, keep)]
                lsum = probs[0]
                for p_ in probs[1:]:
                    lsum = lsum + p_
                lsum = lsum + fx.Float32(fx.gpu.shuffle_xor(lsum, 16, 64))
                lsum = lsum + fx.Float32(fx.gpu.shuffle_xor(lsum, 32, 64))
                lds_store(fx.Int32(off_sum) + (wave * fx.Int32(16) + l16) * fx.Int32(4), fx.Float32,
                          Vec.from_elements([lsum], fx.Float32))

                # O = P . V over this wave's 64 tokens: A = P (row = head l16, k = token 4r + i),
                # B = V chunk read transposed from LDS (k = token 4r + i, column = d).
                o = [Vec.filled(4, 0.0, fx.Float32) for _ in range_constexpr(D // 16)]
                v_base = fx.Int32(off_v) + wave * fx.Int32(V_CHUNK_BYTES)
                for c in range_constexpr(NCHUNK):
                    for it in range_constexpr(PACKS // 64):
                        j = fx.Int32(it * 64) + lane
                        row, col = j // fx.Int32(D // 8), fx.Int32(8) * (j % fx.Int32(D // 8))
                        lds_store(v_base + (row * fx.Int32(V_ROW) + col) * fx.Int32(2), elem, v8[c][it])
                    fx.gpu.barrier()
                    a = Vec.from_elements([probs[c * 4 + i] for i in range(4)], fx.Float32).to(elem)
                    for dt in range_constexpr(D // 16):
                        col = fx.Int32(16 * dt) + l16
                        bvals = [lds_load(v_base + ((r * fx.Int32(4) + fx.Int32(i)) * fx.Int32(V_ROW) + col)
                                          * fx.Int32(2), elem, 1)[0] for i in range(4)]
                        o[dt] = mfma(a, as4(bvals), o[dt])
                    fx.gpu.barrier()

                # Sum the waves' partial O (o[dt][i] = O[head 4r + i][d 16 dt + l16]) in LDS.
                for dt in range_constexpr(D // 16):
                    ov = Vec(o[dt])
                    for i in range_constexpr(4):
                        h = r * fx.Int32(4) + fx.Int32(i)
                        d = fx.Int32(16 * dt) + l16
                        lds_store(fx.Int32(off_o) + ((wave * fx.Int32(16) + h) * fx.Int32(D) + d) * fx.Int32(4),
                                  fx.Float32, Vec.from_elements([ov[i]], fx.Float32))
                fx.gpu.barrier()

                # Each thread finishes 4 consecutive (head, d) elements of the 16 x D tile.
                ELEMS = 16 * D
                for it in range_constexpr(ELEMS // (NT * 4)):
                    e = (fx.Int32(it * NT) + tid) * fx.Int32(4)
                    h, d = e // fx.Int32(D), e % fx.Int32(D)
                    total_l = fx.Float32(0.0)
                    for w in range_constexpr(NWAVES):
                        total_l = total_l + lds_load(fx.Int32(off_sum + w * 64) + h * fx.Int32(4), fx.Float32, 1)[0]
                    acc4 = Vec.filled(4, 0.0, fx.Float32)
                    for w in range_constexpr(NWAVES):
                        acc4 = acc4 + lds_load(fx.Int32(off_o) + ((fx.Int32(w * 16) + h) * fx.Int32(D) + d)
                                               * fx.Int32(4), fx.Float32, 4)
                    # A partition whose keys mask_mod removed entirely has l = 0: O = 0.
                    inv_l = (total_l > fx.Float32(0.0)).select(fx.Float32(1.0) / total_l, fx.Float32(0.0))
                    inv = Vec.from_elements([inv_l], fx.Float32).broadcast_to(4)
                    if h < fx.Int32(G):
                        reg = fx.make_rmem_tensor(4, fx.Float32)
                        reg.store(acc4 * inv)
                        row = fx.logical_divide(fx.slice(pout_t, (b, kvh, part, h, None)), fx.make_layout(4, 1))
                        fx.copy(copy_f128, reg, fx.slice(row, (None, d // fx.Int32(4))))

                # Partition LSE (log2 domain) per head: lanes of wave 0 with r == 0.
                if tid < fx.Int32(G):
                    total_l = fx.Float32(0.0)
                    for w in range_constexpr(NWAVES):
                        total_l = total_l + lds_load(fx.Int32(off_sum + w * 64) + tid * fx.Int32(4), fx.Float32, 1)[0]
                    m_h = fx.Float32(NEG_BIG)
                    for w in range_constexpr(NWAVES):
                        m_h = _max(m_h, lds_load(fx.Int32(off_max + w * 64) + tid * fx.Int32(4), fx.Float32, 1)[0])
                    lse_row = fx.slice(plse_t, (b, kvh, part, None))
                    lse_row[tid] = m_h + fx.math.log2(total_l)

        @flyc.jit
        def launch(
            Q: fx.Tensor, K: fx.Tensor, V: fx.Tensor, PageTable: fx.Tensor, SeqUsedK: fx.Tensor,
            POut: fx.Tensor, PLse: fx.Tensor,
            Aux0: fx.Tensor, Aux1: fx.Tensor, Aux2: fx.Tensor, Aux3: fx.Tensor,
            page_size: fx.Int32, softmax_scale: fx.Float32, window_left: fx.Int32,
            batch: fx.Int32, num_parts: fx.Int32, num_kv_heads: fx.Int32, stream: fx.Stream = fx.Stream(None),
        ):
            kernel(Q, K, V, PageTable, SeqUsedK, POut, PLse, Aux0, Aux1, Aux2, Aux3, page_size, softmax_scale,
                   window_left).launch(grid=(batch, num_parts, num_kv_heads), block=(NT, 1, 1), stream=stream)

        return launch

    # ------------------------------------------------------------- reduce ----
    def _build_reduce(self):
        D, G = self.head_dim, self.group
        elem = fx.Float16 if self.dtype == "fp16" else fx.BFloat16
        is_local, has_sink = self.is_local, self.has_learnable_sink
        NT = 256
        PER_THREAD = 4  # consecutive d per thread

        @flyc.kernel(known_block_size=[NT, 1, 1])
        def kernel(POut: fx.Tensor, PLse: fx.Tensor, SeqUsedK: fx.Tensor, Sink: fx.Tensor, O: fx.Tensor,
                   LSE: fx.Tensor, window_left: fx.Int32):
            tid = fx.Int32(fx.thread_idx.x)
            b = fx.Int32(fx.block_idx.x)
            kvh = fx.Int32(fx.block_idx.y)
            pout_t = fx.rocdl.make_buffer_tensor(POut)
            plse_t = fx.rocdl.make_buffer_tensor(PLse)
            o_t = fx.rocdl.make_buffer_tensor(O)
            lse_t = fx.rocdl.make_buffer_tensor(LSE)
            seqlen = fx.Int32(fx.rocdl.make_buffer_tensor(SeqUsedK)[b])
            nparts = (seqlen + fx.Int32(PARTITION - 1)) // fx.Int32(PARTITION)
            first_part = _first_live_partition(is_local, seqlen, window_left)
            copy_f128 = fx.make_copy_atom(fx.rocdl.BufferCopy128b(), fx.Float32)
            copy_o64 = fx.make_copy_atom(fx.rocdl.BufferCopy64b(), elem)

            for it in range_constexpr(-(-(G * D) // (NT * PER_THREAD))):
                e = (fx.Int32(it * NT) + tid) * fx.Int32(PER_THREAD)
                h, d = e // fx.Int32(D), e % fx.Int32(D)
                if h < fx.Int32(G):
                    lse_col = fx.slice(plse_t, (b, kvh, None, h))
                    # One online pass: running max, rescaled weight sum, rescaled output.
                    init = [fx.Float32(NEG_BIG), fx.Float32(0.0), Vec.filled(PER_THREAD, 0.0, fx.Float32)]
                    for p, state in range(first_part, nparts, fx.Int32(1), init=init):
                        lp = fx.Float32(lse_col[fx.Int32(p)])
                        new_m = _max(fx.Float32(state[0]), lp)
                        rescale = fx.math.exp2(fx.Float32(state[0]) - new_m)
                        w = fx.math.exp2(lp - new_m)
                        reg = fx.make_rmem_tensor(PER_THREAD, fx.Float32)
                        row = fx.logical_divide(fx.slice(pout_t, (b, kvh, fx.Int32(p), h, None)),
                                                fx.make_layout(PER_THREAD, 1))
                        fx.copy(copy_f128, fx.slice(row, (None, d // fx.Int32(PER_THREAD))), reg)
                        rv = Vec.from_elements([rescale], fx.Float32).broadcast_to(PER_THREAD)
                        wv = Vec.from_elements([w], fx.Float32).broadcast_to(PER_THREAD)
                        out = yield [new_m, fx.Float32(state[1]) * rescale + w,
                                     Vec(state[2]) * rv + Vec(reg.load()) * wv]
                    m = fx.Float32(out[0])
                    wsum = fx.Float32(out[1])
                    scale, lse = _finish(m, wsum, _sink_log2(has_sink, Sink, kvh * fx.Int32(G) + h))
                    vals = Vec(out[2]) * Vec.from_elements([scale], fx.Float32).broadcast_to(PER_THREAD)
                    reg = fx.make_rmem_tensor(PER_THREAD, elem)
                    reg.store(vals.to(elem))
                    o_row = fx.logical_divide(fx.slice(o_t, (b, kvh * fx.Int32(G) + h, None)),
                                              fx.make_layout(PER_THREAD, 1))
                    fx.copy(copy_o64, reg, fx.slice(o_row, (None, d // fx.Int32(PER_THREAD))))
                    if d == fx.Int32(0):
                        lse_row = fx.slice(lse_t, (b, None))
                        lse_row[kvh * fx.Int32(G) + h] = lse

        @flyc.jit
        def launch(POut: fx.Tensor, PLse: fx.Tensor, SeqUsedK: fx.Tensor, Sink: fx.Tensor, O: fx.Tensor,
                   LSE: fx.Tensor, window_left: fx.Int32, batch: fx.Int32, num_kv_heads: fx.Int32,
                   stream: fx.Stream = fx.Stream(None)):
            kernel(POut, PLse, SeqUsedK, Sink, O, LSE, window_left).launch(
                grid=(batch, num_kv_heads, 1), block=(NT, 1, 1), stream=stream)

        return launch

    # --------------------------------------------------------------- host ----
    def __call__(self, q, k_cache, v_cache, page_table, seqused_k, softmax_scale, out=None, lse=None,
                 window_left=-1, aux_tensors=(), learnable_sink=None, partials=None, stream=None):
        """Returns ``(out [B, Hq, D], lse [B, Hq])``. ``partials`` = ``(pout, plse)`` may be
        preallocated (e.g. for CUDA-graph capture): ``[B, Hk, P, G, D]`` / ``[B, Hk, P, G]``
        fp32 with ``P >= ceil(max_pages * page_size / 256)``. ``window_left`` keeps keys
        ``seqlen - 1 - window_left ..`` (negative: no limit) when built ``is_local``."""
        import torch

        B, Hq, D = q.shape
        Hk, page_size = k_cache.shape[2], k_cache.shape[1]
        if Hq != Hk * self.group or D != self.head_dim:
            raise ValueError("q / cache shapes do not match how this kernel was built")
        if page_table.dtype != torch.int32 or seqused_k.dtype != torch.int32:
            raise ValueError("page_table must be int32 [batch, max_pages], and seqused_k int32 [batch]")
        aux_tensors = tuple(aux_tensors or ())
        if len(aux_tensors) != self.num_aux_tensors:
            raise ValueError(f"kernel built for {self.num_aux_tensors} aux tensors, got {len(aux_tensors)}")
        if (learnable_sink is not None) != self.has_learnable_sink:
            raise ValueError("learnable_sink does not match how this kernel was built")
        if learnable_sink is not None:
            learnable_sink = learnable_sink.to(torch.float32).contiguous()
        num_parts = max(-(-(page_table.shape[1] * page_size) // PARTITION), 1)
        if partials is None:
            pout = torch.empty(B, Hk, num_parts, self.group, D, dtype=torch.float32, device=q.device)
            plse = torch.empty(B, Hk, num_parts, self.group, dtype=torch.float32, device=q.device)
        else:
            pout, plse = partials
        if out is None:
            out = torch.empty(B, Hq, D, dtype=q.dtype, device=q.device)
        if lse is None:
            lse = torch.empty(B, Hq, dtype=torch.float32, device=q.device)
        stream = torch.cuda.current_stream() if stream is None else stream
        aux_slots = aux_tensors + (plse,) * (MAX_AUX_TENSORS - len(aux_tensors))
        self.decode_launcher(q, k_cache, v_cache, page_table, seqused_k, pout, plse, *aux_slots, page_size,
                             float(softmax_scale), int(window_left), B, num_parts, Hk, stream=stream)
        self.reduce_launcher(pout, plse, seqused_k, learnable_sink if learnable_sink is not None else plse,
                             out, lse, int(window_left), B, Hk, stream=stream)
        return out, lse
