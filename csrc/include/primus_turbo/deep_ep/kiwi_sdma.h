/***************************************************************************************************
 * Copyright (c) 2026, Advanced Micro Devices, Inc. All rights reserved.
 *
 * See LICENSE for license information.
 **************************************************************************************************/

#pragma once

#include <algorithm>
#include <cstddef>
#include <cstdint>
#include <hip/hip_runtime.h>

namespace primus_turbo::deep_ep::intranode {

// The receiver reserves one record slot for every row it can receive, in final
// recv_x order, so a dispatch never reuses receive memory: no ring, ACK, or
// in-iteration re-arm. Senders pack rows into local staging. By default each
// destination's rows go out as one SDMA descriptor once every channel has
// packed its part; a positive chunk size instead copies each channel's rows in
// runs of at most that many bytes as they are packed.
// wall_clock64() runs at 100 MHz on CDNA3, unlike the core-clock budget of
// NUM_TIMEOUT_CYCLES, so this is 30 s of real time.
constexpr uint64_t kKiwiSdmaTimeoutTicks = 30ull * 100 * 1000 * 1000;
constexpr uint32_t kKiwiSdmaSentinelWord = 0x7f817f81;
constexpr uint32_t kKiwiSdmaFp8SentinelWord = 0x7f7f7f7f;
constexpr uint32_t kKiwiSdmaScaleSentinelWord = 0x7f800001;

// Host-coherent record of the first protocol failure, read by the proxy
// thread; device printf output is lost when a kernel traps.
enum KiwiSdmaFailureKind : int {
    kKiwiSdmaNoFailure = 0,
    kKiwiSdmaReceiverPrefixTimeout = 1,
    kKiwiSdmaReceiverPayloadTimeout = 2,
    kKiwiSdmaSenderInvokeTimeout = 3,
    kKiwiSdmaInputSentinel = 4,
    kKiwiSdmaNonFiniteScale = 5,
    kKiwiSdmaSenderRowShortfall = 6,
};

struct KiwiSdmaDiag {
    int kind;
    int rank;
    int peer;
    int row;
    uint32_t observed;
    uint64_t value;
    int progress;
    int total;
};

// Byte layout of the KIWI receive region inside the NVL buffer. It starts
// after the bytes TURBO's CU combine uses (turbo_bytes) so a combine between
// two dispatches cannot overwrite armed sentinels. Offsets are identical on
// every rank, which is what lets a sender address a peer's region.
struct KiwiSdmaLayout {
    size_t metadata_bytes;  // int32 source token + num_topk x (int64 expert, float weight)
    size_t hidden_offset;
    size_t scale_offset;
    size_t record_stride;
    int rows_per_chunk;     // 0: one copy per destination
    size_t prefix_offset;   // num_ranks x num_channels int32 channel prefixes
    size_t base_offset;     // num_ranks int32: first row of this rank's data in each peer
    size_t counter_offset;  // num_ranks int32: sender channels done packing, per destination
    size_t rows_offset;     // records, indexed by final recv_x row
    size_t capacity_rows;
    size_t region_bytes;    // prefix + capacity_rows records
};

inline constexpr size_t kiwi_sdma_align_up(size_t value, size_t alignment) {
    return (value + alignment - 1) / alignment * alignment;
}

inline size_t kiwi_sdma_record_stride(int hidden_bytes, int scale_bytes, int num_topk) {
    const size_t metadata =
        sizeof(int32_t) + static_cast<size_t>(num_topk) * (sizeof(int64_t) + sizeof(float));
    const size_t hidden_offset = kiwi_sdma_align_up(metadata, 16);
    const size_t scale_offset = kiwi_sdma_align_up(hidden_offset + hidden_bytes, 16);
    return kiwi_sdma_align_up(scale_offset + scale_bytes, 16);
}

// Channel prefixes, per-peer row bases, and per-destination counters, before
// the records.
inline size_t kiwi_sdma_prefix_bytes(int num_channels, int num_ranks) {
    return kiwi_sdma_align_up(
        static_cast<size_t>(num_ranks) * (num_channels + 2) * sizeof(int32_t), 256);
}

// num_nvl_bytes the KIWI backend needs: TURBO's own region plus a receive
// slot for every row a rank can get (num_ranks x num_max_tokens_per_rank).
inline size_t kiwi_sdma_nvl_buffer_bytes(size_t turbo_bytes, int num_channels, int num_ranks,
                                         int hidden_bytes, int scale_bytes, int num_topk,
                                         size_t num_max_tokens_per_rank) {
    return kiwi_sdma_align_up(turbo_bytes, 256) + kiwi_sdma_prefix_bytes(num_channels, num_ranks) +
           static_cast<size_t>(num_ranks) * num_max_tokens_per_rank *
               kiwi_sdma_record_stride(hidden_bytes, scale_bytes, num_topk);
}

inline KiwiSdmaLayout make_kiwi_sdma_layout(int num_channels, int num_ranks,
                                             int hidden_bytes, int scale_bytes, int num_topk,
                                             size_t turbo_bytes, size_t num_nvl_bytes,
                                             size_t chunk_bytes) {
    KiwiSdmaLayout l{};
    l.metadata_bytes = sizeof(int32_t) +
                       static_cast<size_t>(num_topk) * (sizeof(int64_t) + sizeof(float));
    l.hidden_offset = kiwi_sdma_align_up(l.metadata_bytes, 16);
    l.scale_offset = kiwi_sdma_align_up(l.hidden_offset + hidden_bytes, 16);
    l.record_stride = kiwi_sdma_record_stride(hidden_bytes, scale_bytes, num_topk);
    l.rows_per_chunk = 0;
    if (chunk_bytes > 0)
        l.rows_per_chunk = std::max(1, static_cast<int>(chunk_bytes / l.record_stride));
    l.prefix_offset = kiwi_sdma_align_up(turbo_bytes, 256);
    l.base_offset =
        l.prefix_offset + static_cast<size_t>(num_ranks) * num_channels * sizeof(int32_t);
    l.counter_offset = l.base_offset + static_cast<size_t>(num_ranks) * sizeof(int32_t);
    l.rows_offset = l.prefix_offset + kiwi_sdma_prefix_bytes(num_channels, num_ranks);
    l.capacity_rows =
        num_nvl_bytes > l.rows_offset ? (num_nvl_bytes - l.rows_offset) / l.record_stride : 0;
    l.region_bytes = l.rows_offset - l.prefix_offset + l.capacity_rows * l.record_stride;
    return l;
}

// Arms the channel prefixes and the first num_recv_rows records with
// sentinels, and tells every source peer where its rows start in this rank's
// recv_x. notify_dispatch only fills the receiving rank's column of
// rank_prefix_matrix, so a sender cannot compute that offset itself. Must
// complete on every rank, followed by a barrier, before any peer sends.
void kiwi_sdma_prepare(void** buffer_ptrs, const int* rank_prefix_matrix, int rank,
                       KiwiSdmaLayout layout, int num_recv_rows, int num_channels,
                       int num_ranks, int hidden_bytes, int scale_bytes, bool is_fp8,
                       hipStream_t stream);

void kiwi_sdma_dispatch(
    void* recv_x, float* recv_x_scales, int* recv_src_idx, int64_t* recv_topk_idx,
    float* recv_topk_weights, int* recv_channel_prefix_matrix, int* send_head,
    const void* x, const float* x_scales, const int64_t* topk_idx,
    const float* topk_weights,
    const bool* is_token_in_rank, const int* rank_prefix_matrix,
    const int* channel_prefix_matrix, int num_tokens, int num_worst_tokens,
    int hidden_bytes, int scale_bytes, int num_topk, int num_experts,
    bool is_fp8, void** buffer_ptrs, void* staging,
    int rank, int num_ranks, int num_channels, KiwiSdmaLayout layout,
    void* kiwi_device_context, uint8_t callback_id, KiwiSdmaDiag* diag,
    hipStream_t stream);

} // namespace primus_turbo::deep_ep::intranode
