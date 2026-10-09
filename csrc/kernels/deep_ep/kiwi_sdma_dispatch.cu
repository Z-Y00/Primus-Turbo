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

__device__ __forceinline__ int4 filled_int4(uint32_t word) {
    return make_int4(static_cast<int>(word), static_cast<int>(word),
                     static_cast<int>(word), static_cast<int>(word));
}

__global__ void prepare_kiwi_sdma(void* local_buffer, KiwiSdmaLayout layout,
                                  int hidden_bytes, int scale_bytes, bool is_fp8) {
    auto* base = static_cast<uint8_t*>(local_buffer);
    const size_t recv_words =
        layout.slot_count * layout.chunk_stride / sizeof(uint32_t);
    auto* recv = reinterpret_cast<uint32_t*>(base + layout.recv_offset);
    for (size_t i = static_cast<size_t>(blockIdx.x) * blockDim.x + threadIdx.x;
         i < recv_words; i += static_cast<size_t>(gridDim.x) * blockDim.x)
        recv[i] = kKiwiSdmaSentinelWord;

    const size_t rows = layout.slot_count * layout.rows_per_chunk;
    const size_t hidden_words_per_row = hidden_bytes / sizeof(uint32_t);
    const size_t hidden_words = rows * hidden_words_per_row;
    for (size_t i = static_cast<size_t>(blockIdx.x) * blockDim.x + threadIdx.x;
         i < hidden_words; i += static_cast<size_t>(gridDim.x) * blockDim.x) {
        const size_t row = i / hidden_words_per_row;
        const size_t word = i % hidden_words_per_row;
        const size_t slot = row / layout.rows_per_chunk;
        const size_t slot_row = row % layout.rows_per_chunk;
        auto* ptr = reinterpret_cast<uint32_t*>(
            base + layout.recv_offset + slot * layout.chunk_stride +
            layout.record_offset + slot_row * layout.record_stride +
            layout.hidden_offset);
        ptr[word] = is_fp8 ? kKiwiSdmaFp8SentinelWord : kKiwiSdmaSentinelWord;
    }
    const size_t scale_words_per_row = scale_bytes / sizeof(uint32_t);
    const size_t scale_words = rows * scale_words_per_row;
    for (size_t i = static_cast<size_t>(blockIdx.x) * blockDim.x + threadIdx.x;
         i < scale_words; i += static_cast<size_t>(gridDim.x) * blockDim.x) {
        const size_t row = i / scale_words_per_row;
        const size_t word = i % scale_words_per_row;
        const size_t slot = row / layout.rows_per_chunk;
        const size_t slot_row = row % layout.rows_per_chunk;
        auto* ptr = reinterpret_cast<uint32_t*>(
            base + layout.recv_offset + slot * layout.chunk_stride +
            layout.record_offset + slot_row * layout.record_stride +
            layout.scale_offset);
        ptr[word] = kKiwiSdmaScaleSentinelWord;
    }

    auto* acks = reinterpret_cast<uint64_t*>(base + layout.ack_offset);
    for (size_t i = static_cast<size_t>(blockIdx.x) * blockDim.x + threadIdx.x;
         i < layout.slot_count; i += static_cast<size_t>(gridDim.x) * blockDim.x)
        acks[i] = 0;
}

__global__ void __launch_bounds__(256)
dispatch_kiwi_sdma(
    void* recv_x_raw, float* recv_x_scales, int* recv_src_idx, int64_t* recv_topk_idx,
    float* recv_topk_weights, int* recv_channel_prefix_matrix, int* send_head,
    const void* x_raw, const float* x_scales, const int64_t* topk_idx,
    const float* topk_weights,
    const bool* is_token_in_rank, const int* rank_prefix_matrix,
    const int* channel_prefix_matrix, int num_tokens, int hidden_bytes,
    int scale_bytes, int num_topk, int num_experts, bool is_fp8,
    void** buffer_ptrs, int rank, int num_ranks, int num_channels,
    KiwiSdmaLayout layout, KiwiDeviceContext* kiwi_context, uint8_t callback_id) {
    const int task = static_cast<int>(blockIdx.x) >> 1;
    const bool sender = (blockIdx.x & 1) == 0;
    const int peer = task % num_ranks;
    const int tid = static_cast<int>(threadIdx.x);
    const int hidden_int4 = hidden_bytes / sizeof(int4);
    const int scale_int4 = scale_bytes / sizeof(int4);
    const int num_experts_per_rank = num_experts / num_ranks;
    auto* local_base = static_cast<uint8_t*>(buffer_ptrs[rank]);
    extern __shared__ int4 hidden_lds[];
    int4* scale_lds = hidden_lds + hidden_int4;

    const size_t send_peer_base =
        layout.send_offset +
        static_cast<size_t>(peer) * kKiwiSdmaRingDepth * layout.chunk_stride;
    const size_t recv_peer_base =
        layout.recv_offset +
        static_cast<size_t>(peer) * kKiwiSdmaRingDepth * layout.chunk_stride;

    if (sender) {
        const int endpoint = peer;
        auto handle = kiwi_context->get_device_handle(endpoint);
        const int expected_rows =
            channel_prefix_matrix[peer * num_channels + num_channels - 1];
        int cursor = 0;
        int produced = 0;
        uint32_t sequence = 0;

        do {
            const int slot = sequence % kKiwiSdmaRingDepth;
            const size_t ack_index =
                static_cast<size_t>(peer) * kKiwiSdmaRingDepth + slot;
            auto* ack = reinterpret_cast<uint64_t*>(local_base + layout.ack_offset) + ack_index;
            if (sequence >= kKiwiSdmaRingDepth && tid == 0) {
                const uint64_t expected_ack = sequence - kKiwiSdmaRingDepth + 1;
                const auto start = wall_clock64();
                while (static_cast<uint64_t>(ld_volatile_global(ack)) < expected_ack) {
                    if (wall_clock64() - start > NUM_TIMEOUT_CYCLES) {
                        printf("KIWI SDMA sender timeout rank=%d dst=%d slot=%d\n",
                               rank, peer, slot);
                        trap();
                    }
                }
            }
            __syncthreads();

            auto* chunk = local_base + send_peer_base +
                          static_cast<size_t>(slot) * layout.chunk_stride;
            auto* header = reinterpret_cast<KiwiSdmaChunkHeader*>(chunk);
            auto* channel_prefix = reinterpret_cast<int32_t*>(
                chunk + sizeof(KiwiSdmaChunkHeader));
            for (int channel = tid; channel < num_channels; channel += blockDim.x)
                channel_prefix[channel] =
                    channel == 0
                        ? 0
                        : channel_prefix_matrix[
                              peer * num_channels + channel - 1];
            int rows = 0;
            while (rows < layout.rows_per_chunk && produced + rows < expected_rows) {
                __shared__ int selected_token;
                if (tid == 0) {
                    selected_token = -1;
                    while (cursor < num_tokens) {
                        const int candidate = cursor++;
                        if (is_token_in_rank[candidate * num_ranks + peer]) {
                            selected_token = candidate;
                            break;
                        }
                    }
                }
                __syncthreads();
                const int token = selected_token;
                if (token < 0) break;

                auto* record = chunk + layout.record_offset +
                               static_cast<size_t>(rows) * layout.record_stride;
                auto* hidden_dst = reinterpret_cast<int4*>(record + layout.hidden_offset);
                const auto* hidden_src =
                    reinterpret_cast<const int4*>(static_cast<const uint8_t*>(x_raw) +
                                                   static_cast<size_t>(token) * hidden_bytes);
                for (int i = tid; i < hidden_int4; i += blockDim.x) {
                    const int4 value = __ldg(hidden_src + i);
                    if (is_fp8 ? contains_fp8_sentinel(value) : contains_sentinel(value)) {
                        printf("KIWI SDMA input contains sentinel rank=%d token=%d int4=%d\n",
                               rank, token, i);
                        trap();
                    }
                    st_na_global(hidden_dst + i, value);
                }
                auto* scale_dst =
                    reinterpret_cast<int4*>(record + layout.scale_offset);
                const auto* scale_src = reinterpret_cast<const int4*>(
                    reinterpret_cast<const uint8_t*>(x_scales) +
                    static_cast<size_t>(token) * scale_bytes);
                for (int i = tid; i < scale_int4; i += blockDim.x) {
                    const int4 value = __ldg(scale_src + i);
                    if (contains_nonfinite_float(value)) {
                        printf("KIWI SDMA scale contains NaN/Inf rank=%d token=%d int4=%d\n",
                               rank, token, i);
                        trap();
                    }
                    st_na_global(scale_dst + i, value);
                }
                if (tid == 0) {
                    *reinterpret_cast<int32_t*>(record) = token;
                    const int tokens_per_channel =
                        (num_tokens + num_channels - 1) / num_channels;
                    const int token_channel =
                        min(token / tokens_per_channel, num_channels - 1);
                    const int channel_base =
                        token_channel == 0
                            ? 0
                            : channel_prefix_matrix[
                                  peer * num_channels + token_channel - 1];
                    send_head[token * num_ranks + peer] =
                        produced + rows - channel_base;
                }
                for (int k = tid; k < num_topk; k += blockDim.x) {
                    const int64_t expert = topk_idx[token * num_topk + k];
                    const int64_t first = static_cast<int64_t>(peer) * num_experts_per_rank;
                    const bool local = expert >= first && expert < first + num_experts_per_rank;
                    reinterpret_cast<int64_t*>(record + sizeof(int32_t))[k] =
                        local ? expert - first : -1;
                    reinterpret_cast<float*>(
                        record + sizeof(int32_t) +
                        static_cast<size_t>(num_topk) * sizeof(int64_t))[k] =
                        local ? topk_weights[token * num_topk + k] : 0.0f;
                }
                __syncthreads();
                ++rows;
            }

            const bool final = produced + rows == expected_rows;
            if (tid == 0) {
                header->rows = static_cast<uint16_t>(rows);
                header->final = final ? 1 : 0;
                header->sequence = sequence;
                header->channel_start = 0;
                header->magic = kKiwiSdmaHeaderMagic;
            }
            __syncthreads();
            __threadfence_system();
            __syncthreads();

            const size_t bytes = layout.record_offset +
                                 static_cast<size_t>(rows) * layout.record_stride;
            auto* remote_chunk =
                static_cast<uint8_t*>(buffer_ptrs[peer]) + layout.recv_offset +
                static_cast<size_t>(rank) * kKiwiSdmaRingDepth *
                    layout.chunk_stride +
                static_cast<size_t>(slot) * layout.chunk_stride;
            if (tid < kWarpSize) {
                while (!handle.invoke(callback_id,
                                      reinterpret_cast<uint64_t>(remote_chunk),
                                      reinterpret_cast<uint64_t>(chunk),
                                      static_cast<uint64_t>(bytes))) {
                }
            }
            __syncthreads();
            produced += rows;
            ++sequence;
            if (final) break;
        } while (true);
        if (tid < kWarpSize)
            kiwi_context->save_device_handle(peer, handle);
        return;
    }

    // Receiver: each block consumes one source/channel stream.
    const int source = peer;
    const int rank_offset =
        source == 0 ? 0 : rank_prefix_matrix[(source - 1) * num_ranks + rank];
    int received = 0;
    uint32_t sequence = 0;
    bool final = false;
    do {
        const int slot = sequence % kKiwiSdmaRingDepth;
        auto* chunk = local_base + recv_peer_base +
                      static_cast<size_t>(slot) * layout.chunk_stride;
        auto* header = reinterpret_cast<KiwiSdmaChunkHeader*>(chunk);
        __shared__ int shared_rows;
        __shared__ int shared_final;
        __shared__ int shared_ready;

        if (tid == 0) {
            const auto start = wall_clock64();
            for (;;) {
                const uint32_t magic = static_cast<uint32_t>(
                    ld_volatile_global(reinterpret_cast<volatile int*>(&header->magic)));
                const uint32_t seq = static_cast<uint32_t>(
                    ld_volatile_global(reinterpret_cast<volatile int*>(&header->sequence)));
                if (magic == kKiwiSdmaHeaderMagic && seq == sequence) break;
                if (wall_clock64() - start > NUM_TIMEOUT_CYCLES) {
                    printf("KIWI SDMA receiver timeout rank=%d src=%d slot=%d\n",
                           rank, source, slot);
                    trap();
                }
            }
            shared_rows = header->rows;
            shared_final = header->final;
        }
        __syncthreads();
        if (sequence == 0) {
            const auto* channel_prefix = reinterpret_cast<const int32_t*>(
                chunk + sizeof(KiwiSdmaChunkHeader));
            for (int channel = tid; channel < num_channels; channel += blockDim.x) {
                const auto start = wall_clock64();
                int value;
                do {
                    value = ld_nc_global(channel_prefix + channel);
                    if (wall_clock64() - start > NUM_TIMEOUT_CYCLES) {
                        printf("KIWI SDMA prefix timeout rank=%d src=%d channel=%d\n",
                               rank, source, channel);
                        trap();
                    }
                } while (static_cast<uint32_t>(value) == kKiwiSdmaSentinelWord);
                recv_channel_prefix_matrix[source * num_channels + channel] = value;
            }
            __syncthreads();
        }

        for (int row = 0; row < shared_rows; ++row) {
            auto* record = chunk + layout.record_offset +
                           static_cast<size_t>(row) * layout.record_stride;
            auto* hidden_src = reinterpret_cast<const int4*>(record + layout.hidden_offset);
            auto* scale_src =
                reinterpret_cast<const int4*>(record + layout.scale_offset);
            const auto start = wall_clock64();
            for (;;) {
                if (tid == 0) shared_ready = 1;
                __syncthreads();
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
                if (tid == 0 && wall_clock64() - start > NUM_TIMEOUT_CYCLES) {
                    printf("KIWI SDMA payload timeout rank=%d src=%d seq=%u row=%d\n",
                           rank, source, sequence, row);
                    trap();
                }
                __syncthreads();
            }

            const int output_row = rank_offset + received + row;
            auto* hidden_dst =
                reinterpret_cast<int4*>(static_cast<uint8_t*>(recv_x_raw) +
                                         static_cast<size_t>(output_row) * hidden_bytes);
            for (int i = tid; i < hidden_int4; i += blockDim.x)
                st_na_global(hidden_dst + i, hidden_lds[i]);
            auto* scale_dst = reinterpret_cast<int4*>(
                reinterpret_cast<uint8_t*>(recv_x_scales) +
                static_cast<size_t>(output_row) * scale_bytes);
            for (int i = tid; i < scale_int4; i += blockDim.x)
                st_na_global(scale_dst + i, scale_lds[i]);
            if (tid == 0 && recv_src_idx)
                recv_src_idx[output_row] = ld_nc_global(
                    reinterpret_cast<const int32_t*>(record));
            for (int k = tid; k < num_topk; k += blockDim.x) {
                if (recv_topk_idx)
                    recv_topk_idx[static_cast<size_t>(output_row) * num_topk + k] =
                        ld_nc_global(reinterpret_cast<const int64_t*>(
                            record + sizeof(int32_t)) + k);
                if (recv_topk_weights)
                    recv_topk_weights[static_cast<size_t>(output_row) * num_topk + k] =
                        ld_nc_global(reinterpret_cast<const float*>(
                            record + sizeof(int32_t) +
                            static_cast<size_t>(num_topk) * sizeof(int64_t)) + k);
            }
            __syncthreads();
            for (int i = tid; i < hidden_int4; i += blockDim.x)
                st_na_global(const_cast<int4*>(hidden_src) + i,
                             filled_int4(is_fp8 ? kKiwiSdmaFp8SentinelWord
                                               : kKiwiSdmaSentinelWord));
            for (int i = tid; i < scale_int4; i += blockDim.x)
                st_na_global(const_cast<int4*>(scale_src) + i,
                             filled_int4(kKiwiSdmaScaleSentinelWord));
            __syncthreads();
        }

        if (tid == 0) {
            header->magic = kKiwiSdmaSentinelWord;
            __threadfence_system();
            const size_t ack_index =
                static_cast<size_t>(rank) * kKiwiSdmaRingDepth + slot;
            auto* remote_ack = reinterpret_cast<uint64_t*>(
                static_cast<uint8_t*>(buffer_ptrs[source]) + layout.ack_offset) + ack_index;
            __hip_atomic_store(remote_ack, static_cast<uint64_t>(sequence + 1),
                               __ATOMIC_RELEASE, __HIP_MEMORY_SCOPE_SYSTEM);
        }
        __syncthreads();
        received += shared_rows;
        final = shared_final != 0;
        ++sequence;
    } while (!final);
}

void kiwi_sdma_prepare(void* local_buffer, KiwiSdmaLayout layout, int hidden_bytes,
                       int scale_bytes, bool is_fp8, hipStream_t stream) {
    const int blocks = static_cast<int>(
        std::min<size_t>(1024, (layout.total_bytes + 255) / 256));
    prepare_kiwi_sdma<<<blocks, 256, 0, stream>>>(
        local_buffer, layout, hidden_bytes, scale_bytes, is_fp8);
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
    bool is_fp8, void** buffer_ptrs, int rank, int num_ranks, int num_channels,
    KiwiSdmaLayout layout, void* kiwi_device_context, uint8_t callback_id,
    hipStream_t stream) {
    PRIMUS_TURBO_CHECK(hidden_bytes % sizeof(int4) == 0);
    PRIMUS_TURBO_CHECK(scale_bytes % sizeof(int4) == 0);
    PRIMUS_TURBO_CHECK(layout.total_bytes > 0);
    if (num_worst_tokens > 0 && recv_topk_idx)
        PRIMUS_TURBO_CHECK_HIP(
            hipMemsetAsync(recv_topk_idx, 0xff,
                           static_cast<size_t>(num_worst_tokens) * num_topk * sizeof(int64_t),
                           stream));
    PRIMUS_TURBO_CHECK_HIP(
        hipMemsetAsync(send_head, 0xff,
                       static_cast<size_t>(num_tokens) * num_ranks * sizeof(int), stream));
    const dim3 grid(2 * num_ranks);
    dispatch_kiwi_sdma<<<grid, 256, hidden_bytes + scale_bytes, stream>>>(
        recv_x, recv_x_scales, recv_src_idx, recv_topk_idx, recv_topk_weights,
        recv_channel_prefix_matrix, send_head, x, x_scales, topk_idx, topk_weights,
        is_token_in_rank, rank_prefix_matrix, channel_prefix_matrix, num_tokens,
        hidden_bytes, scale_bytes, num_topk, num_experts, is_fp8, buffer_ptrs,
        rank, num_ranks, num_channels, layout,
        static_cast<KiwiDeviceContext*>(kiwi_device_context), callback_id);
    PRIMUS_TURBO_CHECK_HIP(hipGetLastError());
}

} // namespace primus_turbo::deep_ep::intranode
