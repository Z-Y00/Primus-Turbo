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

constexpr int kSendThreads = 512;
constexpr int kSendWaves = kSendThreads / kWarpSize;
constexpr int kUnpackThreads = 512;
constexpr int kUnpackBlocksPerSource = 16;

// Records a protocol failure in diag (host-coherent, read by the proxy thread)
// and prints it. Callers then end their block so the kernel completes and the
// printf output is flushed.
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

__global__ void prepare_kiwi_sdma(void** buffer_ptrs, const int* rank_prefix_matrix, int rank,
                                  int num_ranks, KiwiSdmaLayout layout, bool reset_flags) {
    const int source = static_cast<int>(threadIdx.x);
    if (source >= num_ranks) return;
    auto* local = static_cast<uint8_t*>(buffer_ptrs[rank]);
    // Rows from source s start at this rank's column prefix; publish it into
    // s's base slot for this rank. Visible to s after the following barrier.
    const int row_base = source == 0 ? 0 : rank_prefix_matrix[(source - 1) * num_ranks + rank];
    auto* remote_base = reinterpret_cast<int*>(static_cast<uint8_t*>(buffer_ptrs[source]) +
                                               layout.base_offset) +
                        rank;
    __hip_atomic_store(remote_base, row_base, __ATOMIC_RELEASE, __HIP_MEMORY_SCOPE_SYSTEM);
    reinterpret_cast<int*>(local + layout.counter_offset)[source] = 0;
    if (reset_flags) reinterpret_cast<uint64_t*>(local + layout.flag_offset)[source] = 0;
}

// One block per (destination peer, channel). The block computes the row
// position of every token in its channel with a block-wide scan, packs one row
// per wavefront, and posts SDMA copies of the packed rows. Rows for this GPU
// are written straight into the outputs instead.
__global__ void __launch_bounds__(kSendThreads)
send_kiwi_sdma(
    void* recv_x_raw, float* recv_x_scales, int* recv_src_idx, int64_t* recv_topk_idx,
    float* recv_topk_weights, int* recv_channel_prefix_matrix, int* send_head,
    const void* x_raw, const float* x_scales, const int64_t* topk_idx,
    const float* topk_weights, const bool* is_token_in_rank, const int* channel_prefix_matrix,
    int num_tokens, int hidden_bytes, int scale_bytes, int num_topk, int num_experts,
    void** buffer_ptrs, uint8_t* staging, int rank, int num_ranks, int num_channels,
    KiwiSdmaLayout layout, uint64_t epoch, KiwiDeviceContext* kiwi_context,
    uint8_t copy_callback_id, uint8_t flag_callback_id, KiwiSdmaDiag* diag) {
    const int peer = static_cast<int>(blockIdx.x) / num_channels;
    const int channel = static_cast<int>(blockIdx.x) % num_channels;
    const int tid = static_cast<int>(threadIdx.x);
    const int lane = tid % kWarpSize;
    const int wave = tid / kWarpSize;
    const int hidden_int4 = hidden_bytes / sizeof(int4);
    const int scale_int4 = scale_bytes / sizeof(int4);
    const int num_experts_per_rank = num_experts / num_ranks;
    const bool local = peer == rank;

    __shared__ int tile_tokens[kSendThreads];
    __shared__ int wave_count[kSendWaves];
    __shared__ int wave_base[kSendWaves];
    __shared__ int tile_rows;
    __shared__ int aborted;
    if (tid == 0) aborted = 0;

    int token_begin = 0, token_end = 0;
    get_channel_task_range(num_tokens, num_channels, channel, token_begin, token_end);
    const int row_begin =
        channel == 0 ? 0 : channel_prefix_matrix[peer * num_channels + channel - 1];
    const int row_end = channel_prefix_matrix[peer * num_channels + channel];
    auto* local_base = static_cast<uint8_t*>(buffer_ptrs[rank]);
    auto* peer_base = static_cast<uint8_t*>(buffer_ptrs[peer]);
    // Published by the peer's prepare step before the barrier.
    const int peer_row_base = __hip_atomic_load(
        reinterpret_cast<const int*>(local_base + layout.base_offset) + peer, __ATOMIC_ACQUIRE,
        __HIP_MEMORY_SCOPE_SYSTEM);
    // Staging rows for peer p occupy [p * num_tokens, (p + 1) * num_tokens).
    uint8_t* peer_staging =
        staging + static_cast<size_t>(peer) * num_tokens * layout.record_stride;

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

    auto handle = kiwi_context->get_device_handle(peer * num_channels + channel);
    // invoke() is wave-cooperative: wave 0 submits, lane 0's clock decides timeouts.
    auto submit = [&](uint8_t callback, uint64_t a, uint64_t b, uint64_t c, int row_hint) {
        if (wave != 0) return;
        const auto start = wall_clock64();
        while (!(callback == copy_callback_id ? handle.invoke(callback, a, b, c)
                                              : handle.invoke(callback, a, b))) {
            const uint64_t elapsed = __shfl(wall_clock64() - start, 0);
            if (elapsed > kKiwiSdmaTimeoutTicks) {
                if (lane == 0) {
                    report_failure(diag, kKiwiSdmaSenderInvokeTimeout, rank, peer, row_hint,
                                   callback, c, row_hint, row_end);
                    aborted = 1;
                }
                break;
            }
        }
    };
    auto submit_rows = [&](int first_row, int num_rows) {
        submit(copy_callback_id,
               reinterpret_cast<uint64_t>(peer_base + layout.rows_offset +
                                          static_cast<size_t>(peer_row_base + first_row) *
                                              layout.record_stride),
               reinterpret_cast<uint64_t>(peer_staging +
                                          static_cast<size_t>(first_row) * layout.record_stride),
               static_cast<uint64_t>(num_rows) * layout.record_stride, first_row);
    };

    int row = row_begin;
    int chunk_first = row_begin;
    for (int tile = token_begin; tile < token_end; tile += kSendThreads) {
        // Block-wide exclusive scan of the tokens routed to peer.
        const int token = tile + tid;
        const bool selected = token < token_end && is_token_in_rank[token * num_ranks + peer];
        const uint64_t mask = __ballot(selected);
        const int lane_prefix = __popcll(mask & ((1ull << lane) - 1));
        if (lane == 0) wave_count[wave] = __popcll(mask);
        __syncthreads();
        if (tid == 0) {
            int total = 0;
            for (int w = 0; w < kSendWaves; ++w) {
                wave_base[w] = total;
                total += wave_count[w];
            }
            tile_rows = total;
        }
        __syncthreads();
        if (selected) tile_tokens[wave_base[wave] + lane_prefix] = token;
        __syncthreads();

        for (int i = wave; i < tile_rows; i += kSendWaves) {
            const int src_token = tile_tokens[i];
            const int out = row + i;
            const auto* hidden_src = reinterpret_cast<const int4*>(
                static_cast<const uint8_t*>(x_raw) + static_cast<size_t>(src_token) * hidden_bytes);
            const auto* scale_src = reinterpret_cast<const int4*>(
                reinterpret_cast<const uint8_t*>(x_scales) +
                static_cast<size_t>(src_token) * scale_bytes);
            if (lane == 0) send_head[src_token * num_ranks + peer] = out - row_begin;
            if (local) {
                const size_t output_row = static_cast<size_t>(peer_row_base + out);
                auto* hidden_dst = reinterpret_cast<int4*>(static_cast<uint8_t*>(recv_x_raw) +
                                                           output_row * hidden_bytes);
                for (int j = lane; j < hidden_int4; j += kWarpSize)
                    st_na_global(hidden_dst + j, __ldg(hidden_src + j));
                auto* scale_dst = reinterpret_cast<int4*>(
                    reinterpret_cast<uint8_t*>(recv_x_scales) + output_row * scale_bytes);
                for (int j = lane; j < scale_int4; j += kWarpSize)
                    st_na_global(scale_dst + j, __ldg(scale_src + j));
                if (lane == 0 && recv_src_idx) recv_src_idx[output_row] = src_token;
                for (int k = lane; k < num_topk; k += kWarpSize) {
                    const int64_t expert = topk_idx[src_token * num_topk + k];
                    const int64_t first = static_cast<int64_t>(rank) * num_experts_per_rank;
                    const bool mine = expert >= first && expert < first + num_experts_per_rank;
                    if (recv_topk_idx)
                        recv_topk_idx[output_row * num_topk + k] = mine ? expert - first : -1;
                    if (recv_topk_weights)
                        recv_topk_weights[output_row * num_topk + k] =
                            mine ? topk_weights[src_token * num_topk + k] : 0.0f;
                }
            } else {
                auto* record = peer_staging + static_cast<size_t>(out) * layout.record_stride;
                auto* hidden_dst = reinterpret_cast<int4*>(record + layout.hidden_offset);
                for (int j = lane; j < hidden_int4; j += kWarpSize)
                    hidden_dst[j] = __ldg(hidden_src + j);
                auto* scale_dst = reinterpret_cast<int4*>(record + layout.scale_offset);
                for (int j = lane; j < scale_int4; j += kWarpSize)
                    scale_dst[j] = __ldg(scale_src + j);
                if (lane == 0) *reinterpret_cast<int32_t*>(record) = src_token;
                for (int k = lane; k < num_topk; k += kWarpSize) {
                    const int64_t expert = topk_idx[src_token * num_topk + k];
                    const int64_t first = static_cast<int64_t>(peer) * num_experts_per_rank;
                    const bool mine = expert >= first && expert < first + num_experts_per_rank;
                    reinterpret_cast<int64_t*>(record + sizeof(int32_t))[k] =
                        mine ? expert - first : -1;
                    reinterpret_cast<float*>(record + sizeof(int32_t) +
                                             static_cast<size_t>(num_topk) * sizeof(int64_t))[k] =
                        mine ? topk_weights[src_token * num_topk + k] : 0.0f;
                }
            }
        }
        row += tile_rows;
        const bool last_tile = tile + kSendThreads >= token_end;
        if (!local && layout.rows_per_chunk > 0 && row > chunk_first &&
            (last_tile || row - chunk_first >= layout.rows_per_chunk)) {
            // Every wave's staging writes must be visible to the SDMA engine.
            __threadfence_system();
            __syncthreads();
            submit_rows(chunk_first, row - chunk_first);
            chunk_first = row;
        }
        __syncthreads();
        if (aborted) break;
    }

    if (!aborted && row != row_end && tid == 0)
        report_failure(diag, kKiwiSdmaSenderRowShortfall, rank, peer, row,
                       static_cast<uint32_t>(channel), static_cast<uint64_t>(row_end),
                       row - row_begin, row_end - row_begin);

    if (!local && !aborted) {
        // The channel that finishes last posts the destination's data copy
        // (one-copy mode) and then its flag. Each block's system fence makes
        // its staging rows and posted copies visible before it is counted.
        __threadfence_system();
        __syncthreads();
        __shared__ int is_last;
        if (tid == 0) {
            auto* counter = reinterpret_cast<int*>(local_base + layout.counter_offset) + peer;
            is_last = __hip_atomic_fetch_add(counter, 1, __ATOMIC_ACQ_REL,
                                             __HIP_MEMORY_SCOPE_AGENT) == num_channels - 1;
        }
        __syncthreads();
        if (is_last) {
            const int total_rows = channel_prefix_matrix[peer * num_channels + num_channels - 1];
            if (layout.rows_per_chunk == 0 && total_rows > 0) submit_rows(0, total_rows);
            const uint64_t flag = reinterpret_cast<uint64_t>(
                reinterpret_cast<uint64_t*>(peer_base + layout.flag_offset) + rank);
            submit(flag_callback_id, flag, epoch, 0, total_rows);
        }
    }
    // Every exit saves the handle: it carries the queue's producer index into
    // the next launch.
    if (wave == 0) kiwi_context->save_device_handle(peer * num_channels + channel, handle);
}

// One small block: waits until every peer's flag reaches this dispatch's epoch.
// It occupies a single workgroup while the copies are in flight.
__global__ void wait_kiwi_sdma(void** buffer_ptrs, int rank, int num_ranks,
                               KiwiSdmaLayout layout, uint64_t epoch, KiwiSdmaDiag* diag) {
    const int source = static_cast<int>(threadIdx.x);
    if (source >= num_ranks || source == rank) return;
    const auto* flag = reinterpret_cast<const volatile uint64_t*>(
                           static_cast<uint8_t*>(buffer_ptrs[rank]) + layout.flag_offset) +
                       source;
    const auto start = wall_clock64();
    while (*flag < epoch) {
        if (wall_clock64() - start > kKiwiSdmaTimeoutTicks) {
            report_failure(diag, kKiwiSdmaFlagTimeout, rank, source, 0,
                           static_cast<uint32_t>(*flag), epoch, 0, 0);
            return;
        }
    }
    __threadfence_system();
}

// Copies the records that arrived from each peer into the outputs, one row per
// wavefront. Launched after wait_kiwi_sdma on the same stream.
__global__ void __launch_bounds__(kUnpackThreads)
unpack_kiwi_sdma(void* recv_x_raw, float* recv_x_scales, int* recv_src_idx,
                 int64_t* recv_topk_idx, float* recv_topk_weights,
                 int* recv_channel_prefix_matrix, const int* rank_prefix_matrix,
                 int hidden_bytes, int scale_bytes, int num_topk, void** buffer_ptrs, int rank,
                 int num_ranks, int num_channels, KiwiSdmaLayout layout) {
    const int source = static_cast<int>(blockIdx.x) / kUnpackBlocksPerSource;
    const int part = static_cast<int>(blockIdx.x) % kUnpackBlocksPerSource;
    if (source == rank) return;
    const int tid = static_cast<int>(threadIdx.x);
    const int lane = tid % kWarpSize;
    const int wave = tid / kWarpSize;
    constexpr int kWaves = kUnpackThreads / kWarpSize;
    const int hidden_int4 = hidden_bytes / sizeof(int4);
    const int scale_int4 = scale_bytes / sizeof(int4);
    const auto* local_base = static_cast<const uint8_t*>(buffer_ptrs[rank]);

    if (part == 0)
        for (int c = tid; c < num_channels; c += blockDim.x)
            recv_channel_prefix_matrix[source * num_channels + c] =
                reinterpret_cast<const int*>(local_base + layout.prefix_offset)
                    [source * num_channels + c];

    const int rank_offset =
        source == 0 ? 0 : rank_prefix_matrix[(source - 1) * num_ranks + rank];
    const int num_rows = rank_prefix_matrix[source * num_ranks + rank] - rank_offset;
    for (int row = part * kWaves + wave; row < num_rows; row += kUnpackBlocksPerSource * kWaves) {
        const size_t output_row = static_cast<size_t>(rank_offset + row);
        const auto* record = local_base + layout.rows_offset + output_row * layout.record_stride;
        const auto* hidden_src = reinterpret_cast<const int4*>(record + layout.hidden_offset);
        auto* hidden_dst = reinterpret_cast<int4*>(static_cast<uint8_t*>(recv_x_raw) +
                                                   output_row * hidden_bytes);
        for (int j = lane; j < hidden_int4; j += kWarpSize)
            st_na_global(hidden_dst + j, ld_nc_global(hidden_src + j));
        const auto* scale_src = reinterpret_cast<const int4*>(record + layout.scale_offset);
        auto* scale_dst = reinterpret_cast<int4*>(reinterpret_cast<uint8_t*>(recv_x_scales) +
                                                  output_row * scale_bytes);
        for (int j = lane; j < scale_int4; j += kWarpSize)
            st_na_global(scale_dst + j, ld_nc_global(scale_src + j));
        if (lane == 0 && recv_src_idx)
            recv_src_idx[output_row] = ld_nc_global(reinterpret_cast<const int32_t*>(record));
        for (int k = lane; k < num_topk; k += kWarpSize) {
            if (recv_topk_idx)
                recv_topk_idx[output_row * num_topk + k] = ld_nc_global(
                    reinterpret_cast<const int64_t*>(record + sizeof(int32_t)) + k);
            if (recv_topk_weights)
                recv_topk_weights[output_row * num_topk + k] = ld_nc_global(
                    reinterpret_cast<const float*>(record + sizeof(int32_t) +
                                                   static_cast<size_t>(num_topk) *
                                                       sizeof(int64_t)) +
                    k);
        }
    }
}

void kiwi_sdma_prepare(void** buffer_ptrs, const int* rank_prefix_matrix, int rank,
                       KiwiSdmaLayout layout, int num_ranks, bool reset_flags,
                       hipStream_t stream) {
    prepare_kiwi_sdma<<<1, kWarpSize, 0, stream>>>(buffer_ptrs, rank_prefix_matrix, rank,
                                                   num_ranks, layout, reset_flags);
    PRIMUS_TURBO_CHECK_HIP(hipGetLastError());
}

void kiwi_sdma_send(
    void* recv_x, float* recv_x_scales, int* recv_src_idx, int64_t* recv_topk_idx,
    float* recv_topk_weights, int* recv_channel_prefix_matrix, int* send_head,
    const void* x, const float* x_scales, const int64_t* topk_idx, const float* topk_weights,
    const bool* is_token_in_rank, const int* channel_prefix_matrix, int num_tokens,
    int num_worst_tokens, int hidden_bytes, int scale_bytes, int num_topk, int num_experts,
    void** buffer_ptrs, void* staging, int rank, int num_ranks, int num_channels,
    KiwiSdmaLayout layout, uint64_t epoch, void* kiwi_device_context,
    uint8_t copy_callback_id, uint8_t flag_callback_id, KiwiSdmaDiag* diag,
    hipStream_t stream) {
    PRIMUS_TURBO_CHECK(hidden_bytes % sizeof(int4) == 0);
    PRIMUS_TURBO_CHECK(scale_bytes % sizeof(int4) == 0);
    PRIMUS_TURBO_CHECK(num_ranks <= kWarpSize);
    if (num_worst_tokens > 0 && recv_topk_idx)
        PRIMUS_TURBO_CHECK_HIP(
            hipMemsetAsync(recv_topk_idx, 0xff,
                           static_cast<size_t>(num_worst_tokens) * num_topk * sizeof(int64_t),
                           stream));
    PRIMUS_TURBO_CHECK_HIP(
        hipMemsetAsync(send_head, 0xff,
                       static_cast<size_t>(num_tokens) * num_ranks * sizeof(int), stream));
    send_kiwi_sdma<<<num_ranks * num_channels, kSendThreads, 0, stream>>>(
        recv_x, recv_x_scales, recv_src_idx, recv_topk_idx, recv_topk_weights,
        recv_channel_prefix_matrix, send_head, x, x_scales, topk_idx, topk_weights,
        is_token_in_rank, channel_prefix_matrix, num_tokens, hidden_bytes, scale_bytes, num_topk,
        num_experts, buffer_ptrs, static_cast<uint8_t*>(staging), rank, num_ranks, num_channels,
        layout, epoch, static_cast<KiwiDeviceContext*>(kiwi_device_context), copy_callback_id,
        flag_callback_id, diag);
    PRIMUS_TURBO_CHECK_HIP(hipGetLastError());
}

void kiwi_sdma_receive(
    void* recv_x, float* recv_x_scales, int* recv_src_idx, int64_t* recv_topk_idx,
    float* recv_topk_weights, int* recv_channel_prefix_matrix, const int* rank_prefix_matrix,
    int hidden_bytes, int scale_bytes, int num_topk, void** buffer_ptrs, int rank,
    int num_ranks, int num_channels, KiwiSdmaLayout layout, uint64_t epoch, KiwiSdmaDiag* diag,
    hipStream_t stream) {
    wait_kiwi_sdma<<<1, kWarpSize, 0, stream>>>(buffer_ptrs, rank, num_ranks, layout, epoch,
                                                diag);
    PRIMUS_TURBO_CHECK_HIP(hipGetLastError());
    unpack_kiwi_sdma<<<num_ranks * kUnpackBlocksPerSource, kUnpackThreads, 0, stream>>>(
        recv_x, recv_x_scales, recv_src_idx, recv_topk_idx, recv_topk_weights,
        recv_channel_prefix_matrix, rank_prefix_matrix, hidden_bytes, scale_bytes, num_topk,
        buffer_ptrs, rank, num_ranks, num_channels, layout);
    PRIMUS_TURBO_CHECK_HIP(hipGetLastError());
}

} // namespace primus_turbo::deep_ep::intranode
