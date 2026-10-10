/***************************************************************************************************
 * Copyright (c) 2026, Advanced Micro Devices, Inc. All rights reserved.
 *
 * See LICENSE for license information.
 **************************************************************************************************/

#include "primus_turbo/deep_ep/kiwi_sdma.h"

#include "launch.cuh"
#include "utils.cuh"
#include <kiwi/invoke/device_context.hip.hpp>
#include <algorithm>

namespace primus_turbo::deep_ep::intranode {

using KiwiDeviceContext = kiwi::invoke::DeviceContext<>;

__device__ __forceinline__ bool contains_sentinel(const int4& value) {
    const auto* words = reinterpret_cast<const uint32_t*>(&value);
#pragma unroll
    for (int i = 0; i < 4; ++i) {
        if ((words[i] & 0xffffu) == 0x7f81u || (words[i] >> 16) == 0x7f81u)
            return true;
    }
    return false;
}

__device__ __forceinline__ bool contains_fp8_sentinel(const int4& value) {
    const auto* bytes = reinterpret_cast<const uint8_t*>(&value);
#pragma unroll
    for (int i = 0; i < 16; ++i)
        if (bytes[i] == 0x7f || bytes[i] == 0xff) return true;
    return false;
}

__device__ __forceinline__ bool contains_nonfinite_float(const int4& value) {
    const auto* words = reinterpret_cast<const uint32_t*>(&value);
#pragma unroll
    for (int i = 0; i < 4; ++i)
        if ((words[i] & 0x7f800000u) == 0x7f800000u) return true;
    return false;
}

__device__ __forceinline__ bool contains_scale_sentinel(const int4& value) {
    const auto* words = reinterpret_cast<const uint32_t*>(&value);
#pragma unroll
    for (int i = 0; i < 4; ++i)
        if (words[i] == kKiwiSdmaScaleSentinelWord) return true;
    return false;
}

// Records a protocol failure in diag (host-coherent, read by the proxy thread)
// and prints it. Timeouts then end their block so the kernel completes and the
// printf output is flushed; data errors trap.
__device__ __noinline__ void report_failure(KiwiSdmaDiag* diag, int kind, int rank, int peer,
                                            int row, uint32_t observed, uint64_t value,
                                            int progress, int total) {
    printf("[KIWI_SDMA_DEVICE] kind=%d rank=%d peer=%d row=%d observed=0x%x value=%llu "
           "progress=%d/%d\n",
           kind, rank, peer, row, observed, static_cast<unsigned long long>(value), progress,
           total);
    if (diag != nullptr) {
        volatile KiwiSdmaDiag* d = diag;
        d->rank = rank;
        d->peer = peer;
        d->row = row;
        d->observed = observed;
        d->value = value;
        d->progress = progress;
        d->total = total;
        __threadfence_system();
        d->kind = kind;
        __threadfence_system();
    }
}

__device__ __noinline__ void report_data_error(KiwiSdmaDiag* diag, int kind, int rank, int peer,
                                               int row, uint32_t index, uint64_t token,
                                               int total) {
    report_failure(diag, kind, rank, peer, row, index, token, row, total);
    trap();
}

__global__ void prepare_kiwi_sdma(void** buffer_ptrs, const int* rank_prefix_matrix, int rank,
                                  int num_ranks, KiwiSdmaLayout layout, int num_recv_rows,
                                  int num_prefix_words, int hidden_bytes, int scale_bytes,
                                  bool is_fp8) {
    auto* base = static_cast<uint8_t*>(buffer_ptrs[rank]);
    const size_t stride = static_cast<size_t>(gridDim.x) * blockDim.x;
    const size_t first = static_cast<size_t>(blockIdx.x) * blockDim.x + threadIdx.x;

    // Rows from source s start at this rank's column prefix; publish it into
    // s's base slot for this rank. Visible to s after the following barrier.
    if (first < static_cast<size_t>(num_ranks)) {
        const int source = static_cast<int>(first);
        const int row_base =
            source == 0 ? 0 : rank_prefix_matrix[(source - 1) * num_ranks + rank];
        auto* remote = reinterpret_cast<int*>(static_cast<uint8_t*>(buffer_ptrs[source]) +
                                              layout.base_offset) +
                       rank;
        __hip_atomic_store(remote, row_base, __ATOMIC_RELEASE, __HIP_MEMORY_SCOPE_SYSTEM);
        reinterpret_cast<int*>(base + layout.counter_offset)[source] = 0;
    }

    auto* prefix = reinterpret_cast<uint32_t*>(base + layout.prefix_offset);
    for (size_t i = first; i < static_cast<size_t>(num_prefix_words); i += stride)
        prefix[i] = kKiwiSdmaSentinelWord;

    // Arm only the records this dispatch will receive. Words of a record get the
    // sentinel of the field they hold; padding is left as is and never checked.
    const size_t words_per_record = layout.record_stride / sizeof(uint32_t);
    const size_t metadata_words = layout.metadata_bytes / sizeof(uint32_t);
    const size_t hidden_first = layout.hidden_offset / sizeof(uint32_t);
    const size_t hidden_last = hidden_first + hidden_bytes / sizeof(uint32_t);
    const size_t scale_first = layout.scale_offset / sizeof(uint32_t);
    const size_t scale_last = scale_first + scale_bytes / sizeof(uint32_t);
    const uint32_t hidden_word = is_fp8 ? kKiwiSdmaFp8SentinelWord : kKiwiSdmaSentinelWord;
    auto* rows = reinterpret_cast<uint32_t*>(base + layout.rows_offset);
    const size_t total_words = static_cast<size_t>(num_recv_rows) * words_per_record;
    for (size_t i = first; i < total_words; i += stride) {
        const size_t word = i % words_per_record;
        if (word < metadata_words)
            rows[i] = kKiwiSdmaSentinelWord;
        else if (word >= hidden_first && word < hidden_last)
            rows[i] = hidden_word;
        else if (word >= scale_first && word < scale_last)
            rows[i] = kKiwiSdmaScaleSentinelWord;
    }
}

// Block 2*t is the sender and 2*t+1 the receiver for task t = peer * C + channel.
// Sender (peer, channel) packs the channel's rows for peer into local staging,
// in the exact order and positions the peer's recv_x will hold them, and copies
// runs of up to rows_per_chunk rows into the peer's receive region. Receiver
// (source, channel) drains every C-th row from source starting at channel.
__global__ void __launch_bounds__(256)
dispatch_kiwi_sdma(
    void* recv_x_raw, float* recv_x_scales, int* recv_src_idx, int64_t* recv_topk_idx,
    float* recv_topk_weights, int* recv_channel_prefix_matrix, int* send_head,
    const void* x_raw, const float* x_scales, const int64_t* topk_idx,
    const float* topk_weights,
    const bool* is_token_in_rank, const int* rank_prefix_matrix,
    const int* channel_prefix_matrix, int num_tokens, int hidden_bytes,
    int scale_bytes, int num_topk, int num_experts, bool is_fp8,
    void** buffer_ptrs, uint8_t* staging, int rank, int num_ranks, int num_channels,
    KiwiSdmaLayout layout, KiwiDeviceContext* kiwi_context, uint8_t callback_id,
    KiwiSdmaDiag* diag) {
    const int task = static_cast<int>(blockIdx.x) >> 1;
    const bool sender = (blockIdx.x & 1) == 0;
    const int peer = task / num_channels;
    const int channel = task % num_channels;
    const int tid = static_cast<int>(threadIdx.x);
    const int hidden_int4 = hidden_bytes / sizeof(int4);
    const int scale_int4 = scale_bytes / sizeof(int4);
    const int num_experts_per_rank = num_experts / num_ranks;
    extern __shared__ int4 hidden_lds[];
    int4* scale_lds = hidden_lds + hidden_int4;
    __shared__ int aborted;
    if (tid == 0) aborted = 0;
    __syncthreads();

    if (sender) {
        const int endpoint = peer * num_channels + channel;
        auto handle = kiwi_context->get_device_handle(endpoint);
        int token_begin = 0, token_end = 0;
        get_channel_task_range(num_tokens, num_channels, channel, token_begin, token_end);
        const int row_begin =
            channel == 0 ? 0 : channel_prefix_matrix[peer * num_channels + channel - 1];
        const int row_end = channel_prefix_matrix[peer * num_channels + channel];
        // Published by the peer's prepare step before the barrier.
        const int peer_row_base = __hip_atomic_load(
            reinterpret_cast<const int*>(static_cast<uint8_t*>(buffer_ptrs[rank]) +
                                         layout.base_offset) +
                peer,
            __ATOMIC_ACQUIRE, __HIP_MEMORY_SCOPE_SYSTEM);
        auto* peer_base = static_cast<uint8_t*>(buffer_ptrs[peer]);
        // Rows that stay on this GPU are written straight into the outputs by
        // the CU; only rows for other GPUs go through staging and SDMA.
        const bool local = peer == rank;

        if (tid == 0) {
            if (local) {
                recv_channel_prefix_matrix[rank * num_channels + channel] = row_begin;
            } else {
                auto* remote_prefix = reinterpret_cast<int*>(peer_base + layout.prefix_offset) +
                                      rank * num_channels + channel;
                __hip_atomic_store(remote_prefix, row_begin, __ATOMIC_RELEASE,
                                   __HIP_MEMORY_SCOPE_SYSTEM);
            }
        }

        // Staging rows for peer p occupy [p * num_tokens, (p + 1) * num_tokens).
        uint8_t* peer_staging =
            staging + static_cast<size_t>(peer) * num_tokens * layout.record_stride;
        // Copies num_rows staged rows starting at peer row first_row. invoke() is
        // wave-cooperative, so wave 0 submits and lane 0's clock decides timeouts.
        auto submit = [&](int first_row, int num_rows) {
            if (tid >= kWarpSize) return;
            const uint64_t dst = reinterpret_cast<uint64_t>(
                peer_base + layout.rows_offset +
                static_cast<size_t>(peer_row_base + first_row) * layout.record_stride);
            const uint64_t src = reinterpret_cast<uint64_t>(
                peer_staging + static_cast<size_t>(first_row) * layout.record_stride);
            const uint64_t bytes = static_cast<uint64_t>(num_rows) * layout.record_stride;
            const auto start = wall_clock64();
            while (!handle.invoke(callback_id, dst, src, bytes)) {
                const uint64_t elapsed = __shfl(wall_clock64() - start, 0);
                if (elapsed > kKiwiSdmaTimeoutTicks) {
                    if (tid == 0) {
                        report_failure(diag, kKiwiSdmaSenderInvokeTimeout, rank, peer, first_row,
                                       0, bytes, first_row, num_rows);
                        aborted = 1;
                    }
                    break;
                }
            }
        };

        __shared__ int selected_token;
        int cursor = token_begin;
        int chunk_first = row_begin;
        for (int row = row_begin; row < row_end; ++row) {
            if (tid == 0) {
                selected_token = -1;
                while (cursor < token_end) {
                    const int candidate = cursor++;
                    if (is_token_in_rank[candidate * num_ranks + peer]) {
                        selected_token = candidate;
                        break;
                    }
                }
            }
            __syncthreads();
            const int token = selected_token;
            if (token < 0) {
                // channel_prefix_matrix promised more rows than the channel holds.
                if (tid == 0)
                    report_failure(diag, kKiwiSdmaSenderRowShortfall, rank, peer, row,
                                   static_cast<uint32_t>(channel), cursor, row - row_begin,
                                   row_end - row_begin);
                break;
            }

            if (local) {
                const int output_row = peer_row_base + row;
                const auto* hidden_src = reinterpret_cast<const int4*>(
                    static_cast<const uint8_t*>(x_raw) + static_cast<size_t>(token) * hidden_bytes);
                auto* hidden_dst = reinterpret_cast<int4*>(
                    static_cast<uint8_t*>(recv_x_raw) +
                    static_cast<size_t>(output_row) * hidden_bytes);
                for (int i = tid; i < hidden_int4; i += blockDim.x)
                    st_na_global(hidden_dst + i, __ldg(hidden_src + i));
                const auto* scale_src = reinterpret_cast<const int4*>(
                    reinterpret_cast<const uint8_t*>(x_scales) +
                    static_cast<size_t>(token) * scale_bytes);
                auto* scale_dst = reinterpret_cast<int4*>(
                    reinterpret_cast<uint8_t*>(recv_x_scales) +
                    static_cast<size_t>(output_row) * scale_bytes);
                for (int i = tid; i < scale_int4; i += blockDim.x)
                    st_na_global(scale_dst + i, __ldg(scale_src + i));
                if (tid == 0) {
                    if (recv_src_idx) recv_src_idx[output_row] = token;
                    send_head[token * num_ranks + peer] = row - row_begin;
                }
                for (int k = tid; k < num_topk; k += blockDim.x) {
                    const int64_t expert = topk_idx[token * num_topk + k];
                    const int64_t first = static_cast<int64_t>(rank) * num_experts_per_rank;
                    const bool mine = expert >= first && expert < first + num_experts_per_rank;
                    if (recv_topk_idx)
                        recv_topk_idx[static_cast<size_t>(output_row) * num_topk + k] =
                            mine ? expert - first : -1;
                    if (recv_topk_weights)
                        recv_topk_weights[static_cast<size_t>(output_row) * num_topk + k] =
                            mine ? topk_weights[token * num_topk + k] : 0.0f;
                }
                __syncthreads();
                continue;
            }

            auto* record = peer_staging + static_cast<size_t>(row) * layout.record_stride;
            auto* hidden_dst = reinterpret_cast<int4*>(record + layout.hidden_offset);
            const auto* hidden_src = reinterpret_cast<const int4*>(
                static_cast<const uint8_t*>(x_raw) + static_cast<size_t>(token) * hidden_bytes);
            for (int i = tid; i < hidden_int4; i += blockDim.x) {
                const int4 value = __ldg(hidden_src + i);
                if (is_fp8 ? contains_fp8_sentinel(value) : contains_sentinel(value))
                    report_data_error(diag, kKiwiSdmaInputSentinel, rank, peer, row, i, token,
                                      row_end);
                hidden_dst[i] = value;
            }
            auto* scale_dst = reinterpret_cast<int4*>(record + layout.scale_offset);
            const auto* scale_src = reinterpret_cast<const int4*>(
                reinterpret_cast<const uint8_t*>(x_scales) +
                static_cast<size_t>(token) * scale_bytes);
            for (int i = tid; i < scale_int4; i += blockDim.x) {
                const int4 value = __ldg(scale_src + i);
                if (contains_nonfinite_float(value))
                    report_data_error(diag, kKiwiSdmaNonFiniteScale, rank, peer, row, i, token,
                                      row_end);
                scale_dst[i] = value;
            }
            if (tid == 0) {
                *reinterpret_cast<int32_t*>(record) = token;
                send_head[token * num_ranks + peer] = row - row_begin;
            }
            for (int k = tid; k < num_topk; k += blockDim.x) {
                const int64_t expert = topk_idx[token * num_topk + k];
                const int64_t first = static_cast<int64_t>(peer) * num_experts_per_rank;
                const bool local = expert >= first && expert < first + num_experts_per_rank;
                reinterpret_cast<int64_t*>(record + sizeof(int32_t))[k] =
                    local ? expert - first : -1;
                reinterpret_cast<float*>(record + sizeof(int32_t) +
                                         static_cast<size_t>(num_topk) * sizeof(int64_t))[k] =
                    local ? topk_weights[token * num_topk + k] : 0.0f;
            }

            const bool flush =
                layout.rows_per_chunk > 0 &&
                (row + 1 == row_end || row + 1 - chunk_first == layout.rows_per_chunk);
            if (flush) {
                // Every wave's staging writes must be visible to the SDMA engine.
                __threadfence_system();
                __syncthreads();
                submit(chunk_first, row + 1 - chunk_first);
                chunk_first = row + 1;
            }
            __syncthreads();
            if (aborted) break;
        }

        if (layout.rows_per_chunk == 0 && !local && !aborted) {
            // One descriptor per destination: the channel that finishes packing
            // last copies every channel's rows. Each block's system fence makes
            // its staging rows visible before it is counted.
            __threadfence_system();
            __syncthreads();
            __shared__ int is_last;
            if (tid == 0) {
                auto* counter = reinterpret_cast<int*>(static_cast<uint8_t*>(buffer_ptrs[rank]) +
                                                       layout.counter_offset) +
                                peer;
                is_last = __hip_atomic_fetch_add(counter, 1, __ATOMIC_ACQ_REL,
                                                 __HIP_MEMORY_SCOPE_AGENT) == num_channels - 1;
            }
            __syncthreads();
            const int total_rows = channel_prefix_matrix[peer * num_channels + num_channels - 1];
            if (is_last && total_rows > 0) submit(0, total_rows);
            __syncthreads();
        }
        // Every exit saves the handle: it carries the queue's producer index
        // into the next launch.
        if (tid < kWarpSize) kiwi_context->save_device_handle(endpoint, handle);
        return;
    }

    // Receiver. The sender block wrote this GPU's own rows already.
    const int source = peer;
    if (source == rank) return;
    const int rank_offset =
        source == 0 ? 0 : rank_prefix_matrix[(source - 1) * num_ranks + rank];
    const int num_rows = rank_prefix_matrix[source * num_ranks + rank] - rank_offset;
    auto* local_base = static_cast<uint8_t*>(buffer_ptrs[rank]);

    if (tid == 0) {
        const auto* prefix = reinterpret_cast<const int*>(local_base + layout.prefix_offset) +
                             source * num_channels + channel;
        const auto start = wall_clock64();
        int value;
        for (;;) {
            value = __hip_atomic_load(prefix, __ATOMIC_ACQUIRE, __HIP_MEMORY_SCOPE_SYSTEM);
            if (static_cast<uint32_t>(value) != kKiwiSdmaSentinelWord) break;
            if (wall_clock64() - start > kKiwiSdmaTimeoutTicks) {
                report_failure(diag, kKiwiSdmaReceiverPrefixTimeout, rank, source, channel,
                               static_cast<uint32_t>(value), 0, 0, num_channels);
                aborted = 1;
                break;
            }
        }
        recv_channel_prefix_matrix[source * num_channels + channel] = value;
    }
    __syncthreads();
    if (aborted) return;

    __shared__ int shared_ready;
    const int metadata_words = static_cast<int>(layout.metadata_bytes / sizeof(uint32_t));
    for (int row = channel; row < num_rows; row += num_channels) {
        const int output_row = rank_offset + row;
        const auto* record = local_base + layout.rows_offset +
                             static_cast<size_t>(output_row) * layout.record_stride;
        const auto* metadata = reinterpret_cast<const uint32_t*>(record);
        const auto* hidden_src = reinterpret_cast<const int4*>(record + layout.hidden_offset);
        const auto* scale_src = reinterpret_cast<const int4*>(record + layout.scale_offset);
        const auto start = wall_clock64();
        for (;;) {
            if (tid == 0) shared_ready = 1;
            __syncthreads();
            for (int i = tid; i < metadata_words; i += blockDim.x)
                if (ld_nc_global(metadata + i) == kKiwiSdmaSentinelWord)
                    atomicExch(&shared_ready, 0);
            for (int i = tid; i < hidden_int4; i += blockDim.x) {
                const int4 value = ld_nc_global(hidden_src + i);
                hidden_lds[i] = value;
                if (is_fp8 ? contains_fp8_sentinel(value) : contains_sentinel(value))
                    atomicExch(&shared_ready, 0);
            }
            for (int i = tid; i < scale_int4; i += blockDim.x) {
                const int4 value = ld_nc_global(scale_src + i);
                scale_lds[i] = value;
                if (contains_scale_sentinel(value)) atomicExch(&shared_ready, 0);
            }
            __syncthreads();
            if (shared_ready) break;
            if (tid == 0 && wall_clock64() - start > kKiwiSdmaTimeoutTicks) {
                report_failure(diag, kKiwiSdmaReceiverPayloadTimeout, rank, source, row, 0,
                               static_cast<uint64_t>(output_row), row, num_rows);
                aborted = 1;
            }
            __syncthreads();
            if (aborted) return;
        }

        auto* hidden_dst = reinterpret_cast<int4*>(static_cast<uint8_t*>(recv_x_raw) +
                                                   static_cast<size_t>(output_row) * hidden_bytes);
        for (int i = tid; i < hidden_int4; i += blockDim.x)
            st_na_global(hidden_dst + i, hidden_lds[i]);
        auto* scale_dst = reinterpret_cast<int4*>(reinterpret_cast<uint8_t*>(recv_x_scales) +
                                                  static_cast<size_t>(output_row) * scale_bytes);
        for (int i = tid; i < scale_int4; i += blockDim.x)
            st_na_global(scale_dst + i, scale_lds[i]);
        if (tid == 0 && recv_src_idx)
            recv_src_idx[output_row] = ld_nc_global(reinterpret_cast<const int32_t*>(record));
        for (int k = tid; k < num_topk; k += blockDim.x) {
            if (recv_topk_idx)
                recv_topk_idx[static_cast<size_t>(output_row) * num_topk + k] = ld_nc_global(
                    reinterpret_cast<const int64_t*>(record + sizeof(int32_t)) + k);
            if (recv_topk_weights)
                recv_topk_weights[static_cast<size_t>(output_row) * num_topk + k] =
                    ld_nc_global(reinterpret_cast<const float*>(
                                     record + sizeof(int32_t) +
                                     static_cast<size_t>(num_topk) * sizeof(int64_t)) +
                                 k);
        }
        __syncthreads();
    }
}

void kiwi_sdma_prepare(void** buffer_ptrs, const int* rank_prefix_matrix, int rank,
                       KiwiSdmaLayout layout, int num_recv_rows, int num_channels,
                       int num_ranks, int hidden_bytes, int scale_bytes, bool is_fp8,
                       hipStream_t stream) {
    const size_t words = static_cast<size_t>(num_recv_rows) * layout.record_stride / 4 +
                         static_cast<size_t>(num_ranks) * num_channels;
    const int blocks = static_cast<int>(std::max<size_t>(
        1, std::min<size_t>(4096, (words + 255) / 256)));
    prepare_kiwi_sdma<<<blocks, 256, 0, stream>>>(
        buffer_ptrs, rank_prefix_matrix, rank, num_ranks, layout, num_recv_rows,
        num_ranks * num_channels, hidden_bytes, scale_bytes, is_fp8);
    PRIMUS_TURBO_CHECK_HIP(hipGetLastError());
}

void kiwi_sdma_dispatch(
    void* recv_x, float* recv_x_scales, int* recv_src_idx, int64_t* recv_topk_idx,
    float* recv_topk_weights, int* recv_channel_prefix_matrix, int* send_head,
    const void* x, const float* x_scales, const int64_t* topk_idx,
    const float* topk_weights,
    const bool* is_token_in_rank, const int* rank_prefix_matrix,
    const int* channel_prefix_matrix, int num_tokens, int num_worst_tokens,
    int hidden_bytes, int scale_bytes, int num_topk, int num_experts,
    bool is_fp8, void** buffer_ptrs, void* staging, int rank, int num_ranks, int num_channels,
    KiwiSdmaLayout layout, void* kiwi_device_context, uint8_t callback_id,
    KiwiSdmaDiag* diag, hipStream_t stream) {
    PRIMUS_TURBO_CHECK(hidden_bytes % sizeof(int4) == 0);
    PRIMUS_TURBO_CHECK(scale_bytes % sizeof(int4) == 0);
    if (num_worst_tokens > 0 && recv_topk_idx)
        PRIMUS_TURBO_CHECK_HIP(
            hipMemsetAsync(recv_topk_idx, 0xff,
                           static_cast<size_t>(num_worst_tokens) * num_topk * sizeof(int64_t),
                           stream));
    PRIMUS_TURBO_CHECK_HIP(
        hipMemsetAsync(send_head, 0xff,
                       static_cast<size_t>(num_tokens) * num_ranks * sizeof(int), stream));
    const dim3 grid(2 * num_ranks * num_channels);
    dispatch_kiwi_sdma<<<grid, 256, hidden_bytes + scale_bytes, stream>>>(
        recv_x, recv_x_scales, recv_src_idx, recv_topk_idx, recv_topk_weights,
        recv_channel_prefix_matrix, send_head, x, x_scales, topk_idx, topk_weights,
        is_token_in_rank, rank_prefix_matrix, channel_prefix_matrix, num_tokens,
        hidden_bytes, scale_bytes, num_topk, num_experts, is_fp8, buffer_ptrs,
        static_cast<uint8_t*>(staging), rank, num_ranks, num_channels, layout,
        static_cast<KiwiDeviceContext*>(kiwi_device_context), callback_id, diag);
    PRIMUS_TURBO_CHECK_HIP(hipGetLastError());
}

} // namespace primus_turbo::deep_ep::intranode
