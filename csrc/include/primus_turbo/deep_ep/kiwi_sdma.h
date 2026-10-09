/***************************************************************************************************
 * Copyright (c) 2026, Advanced Micro Devices, Inc. All rights reserved.
 *
 * See LICENSE for license information.
 **************************************************************************************************/

#pragma once

#include <cstddef>
#include <cstdint>
#include <hip/hip_runtime.h>

namespace primus_turbo::deep_ep::intranode {

constexpr int kKiwiSdmaRingDepth = 2;
constexpr size_t kKiwiSdmaTargetChunkBytes = 64 * 1024;
constexpr uint32_t kKiwiSdmaHeaderMagic = 0x4b53444d; // "KSDM"
constexpr uint32_t kKiwiSdmaSentinelWord = 0x7f817f81;
constexpr uint32_t kKiwiSdmaFp8SentinelWord = 0x7f7f7f7f;
constexpr uint32_t kKiwiSdmaScaleSentinelWord = 0x7f800001;

struct KiwiSdmaChunkHeader {
    uint32_t magic;
    uint16_t rows;
    uint16_t final;
    uint32_t sequence;
    uint32_t channel_start;
};
static_assert(sizeof(KiwiSdmaChunkHeader) == 16);

struct KiwiSdmaLayout {
    size_t metadata_bytes;
    size_t hidden_offset;
    size_t scale_offset;
    size_t record_stride;
    int rows_per_chunk;
    size_t chunk_stride;
    size_t slot_count;
    size_t send_offset;
    size_t recv_offset;
    size_t ack_offset;
    size_t total_bytes;
};

inline constexpr size_t kiwi_sdma_align_up(size_t value, size_t alignment) {
    return (value + alignment - 1) / alignment * alignment;
}

inline KiwiSdmaLayout make_kiwi_sdma_layout(int num_channels, int num_ranks,
                                             int hidden_bytes, int scale_bytes,
                                             int num_topk) {
    KiwiSdmaLayout l{};
    l.metadata_bytes = sizeof(int32_t) +
                       static_cast<size_t>(num_topk) * (sizeof(int64_t) + sizeof(float));
    l.hidden_offset = kiwi_sdma_align_up(l.metadata_bytes, 16);
    l.scale_offset = kiwi_sdma_align_up(l.hidden_offset + hidden_bytes, 16);
    l.record_stride = kiwi_sdma_align_up(l.scale_offset + scale_bytes, 16);
    l.rows_per_chunk = static_cast<int>(
        (kKiwiSdmaTargetChunkBytes - sizeof(KiwiSdmaChunkHeader)) / l.record_stride);
    if (l.rows_per_chunk < 1) l.rows_per_chunk = 1;
    l.chunk_stride = kiwi_sdma_align_up(
        sizeof(KiwiSdmaChunkHeader) +
            static_cast<size_t>(l.rows_per_chunk) * l.record_stride,
        256);
    l.slot_count = static_cast<size_t>(num_channels) * num_ranks * kKiwiSdmaRingDepth;
    l.send_offset = 0;
    l.recv_offset = l.slot_count * l.chunk_stride;
    l.ack_offset = l.recv_offset + l.slot_count * l.chunk_stride;
    l.total_bytes = kiwi_sdma_align_up(
        l.ack_offset + l.slot_count * sizeof(uint64_t), 128);
    return l;
}

void kiwi_sdma_prepare(void* local_buffer, KiwiSdmaLayout layout, int hidden_bytes,
                       int scale_bytes, bool is_fp8, hipStream_t stream);

void kiwi_sdma_dispatch(
    void* recv_x, float* recv_x_scales, int* recv_src_idx, int64_t* recv_topk_idx,
    float* recv_topk_weights, int* recv_channel_prefix_matrix, int* send_head,
    const void* x, const float* x_scales, const int64_t* topk_idx,
    const float* topk_weights,
    const bool* is_token_in_rank, const int* rank_prefix_matrix,
    const int* channel_prefix_matrix, int num_tokens, int num_worst_tokens,
    int hidden_bytes, int scale_bytes, int num_topk, int num_experts,
    bool is_fp8, void** buffer_ptrs,
    int rank, int num_ranks, int num_channels, KiwiSdmaLayout layout,
    void* kiwi_device_context, uint8_t callback_id, hipStream_t stream);

} // namespace primus_turbo::deep_ep::intranode
