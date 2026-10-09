/***************************************************************************************************
 * Copyright (c) 2026, Advanced Micro Devices, Inc. All rights reserved.
 *
 * See LICENSE for license information.
 **************************************************************************************************/

#pragma once

#include <cstddef>
#include <cstdint>
#include <hip/hip_runtime.h>

namespace primus_turbo::mega_moe {

inline constexpr uint32_t kBf16SentinelWord = 0x7f817f81u;
// MegaMoE uses E4M3 FNUZ, where 0x7f is a valid finite maximum and 0x80 is
// the sole NaN encoding. Quantization rejects non-finite inputs, reserving
// 0x80 for transport readiness.
inline constexpr uint32_t kFp8SentinelWord = 0x80808080u;
inline constexpr uint32_t kScaleSentinelWord = 0xffffffffu;
inline constexpr size_t kTargetChunkBytes = 64 * 1024;

void launch_kiwi_sdma_pack(
    const void* input, const void* scales, const int* expert_send_dst_rank,
    const int* expert_send_dst_row, const int* expert_send_count,
    const int* expert_send_offset, const int* dispatched_token_idx,
    const int64_t* pool_ptrs, const int64_t* scale_ptrs, void* staging,
    size_t staging_rows, int hidden_bytes, int scale_bytes, int num_tasks,
    bool is_fp8, void* kiwi_device_context, uint8_t callback_id,
    hipStream_t stream);

} // namespace primus_turbo::mega_moe
