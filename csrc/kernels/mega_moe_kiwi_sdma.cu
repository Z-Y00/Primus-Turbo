/***************************************************************************************************
 * Copyright (c) 2026, Advanced Micro Devices, Inc. All rights reserved.
 *
 * See LICENSE for license information.
 **************************************************************************************************/

#include "primus_turbo/mega_moe_kiwi_sdma.h"

#include "primus_turbo/common.h"
#include <kiwi/invoke/device_context.hip.hpp>

namespace primus_turbo::mega_moe {
namespace {

using KiwiDeviceContext = kiwi::invoke::DeviceContext<>;

__device__ __forceinline__ bool invalid_bf16(const int4& value) {
    const auto* words = reinterpret_cast<const uint32_t*>(&value);
#pragma unroll
    for (int i = 0; i < 4; ++i)
        if ((words[i] & 0xffffu) == 0x7f81u || (words[i] >> 16) == 0x7f81u)
            return true;
    return false;
}

__device__ __forceinline__ bool invalid_fp8(const int4& value) {
    const auto* bytes = reinterpret_cast<const uint8_t*>(&value);
#pragma unroll
    for (int i = 0; i < 16; ++i)
        if (bytes[i] == 0x80) return true;
    return false;
}

__global__ void __launch_bounds__(256) pack_and_invoke(
    const uint8_t* input, const uint8_t* scales,
    const int* expert_send_dst_rank, const int* expert_send_dst_row,
    const int* expert_send_count, const int* expert_send_offset,
    const int* dispatched_token_idx, const int64_t* pool_ptrs,
    const int64_t* scale_ptrs, uint8_t* staging, size_t staging_rows,
    int hidden_bytes, int scale_bytes, bool is_fp8,
    KiwiDeviceContext* context, uint8_t callback_id) {
    const int task = static_cast<int>(blockIdx.x);
    const int count = expert_send_count[task];
    const int source_offset = expert_send_offset[task];
    const int hidden_int4 = hidden_bytes / sizeof(int4);
    const int scale_int4 = scale_bytes / sizeof(int4);
    auto* hidden_staging = reinterpret_cast<int4*>(
        staging + static_cast<size_t>(source_offset) * hidden_bytes);
    auto* scale_staging = reinterpret_cast<int4*>(
        staging + staging_rows * hidden_bytes +
        static_cast<size_t>(source_offset) * scale_bytes);

    for (int row = 0; row < count; ++row) {
        const int token = dispatched_token_idx[source_offset + row];
        const auto* hidden_src = reinterpret_cast<const int4*>(
            input + static_cast<size_t>(token) * hidden_bytes);
        for (int i = threadIdx.x; i < hidden_int4; i += blockDim.x) {
            const int4 value = hidden_src[i];
            if (is_fp8 ? invalid_fp8(value) : invalid_bf16(value)) {
                printf("MegaMoE KIWI SDMA input contains reserved sentinel task=%d token=%d word=%d\n",
                       task, token, i);
                __builtin_trap();
            }
            hidden_staging[static_cast<size_t>(row) * hidden_int4 + i] = value;
        }
        if (is_fp8) {
            const auto* scale_src = reinterpret_cast<const int4*>(
                scales + static_cast<size_t>(token) * scale_bytes);
            for (int i = threadIdx.x; i < scale_int4; i += blockDim.x) {
                const int4 value = scale_src[i];
                const auto* bytes = reinterpret_cast<const uint8_t*>(&value);
#pragma unroll
                for (int j = 0; j < 16; ++j)
                    if (bytes[j] == 0xff) {
                        printf("MegaMoE KIWI SDMA scale contains reserved sentinel task=%d token=%d byte=%d\n",
                               task, token, i * 16 + j);
                        __builtin_trap();
                    }
                scale_staging[static_cast<size_t>(row) * scale_int4 + i] = value;
            }
        }
    }
    __syncthreads();
    __threadfence_system();
    __syncthreads();

    if (threadIdx.x < 64 && count > 0) {
        const int dst_rank = expert_send_dst_rank[task];
        const int dst_row = expert_send_dst_row[task];
        const int computed_rows = static_cast<int>(
            (kTargetChunkBytes + hidden_bytes - 1) / hidden_bytes);
        const int rows_per_chunk = computed_rows > 0 ? computed_rows : 1;
        auto handle = context->get_device_handle(task);
        for (int first = 0; first < count; first += rows_per_chunk) {
            const int remaining = count - first;
            const int rows =
                rows_per_chunk < remaining ? rows_per_chunk : remaining;
            const uint64_t hidden_dst =
                static_cast<uint64_t>(pool_ptrs[dst_rank]) +
                static_cast<uint64_t>(dst_row + first) * hidden_bytes;
            const uint64_t hidden_src =
                reinterpret_cast<uint64_t>(hidden_staging) +
                static_cast<uint64_t>(first) * hidden_bytes;
            while (!handle.invoke(callback_id, hidden_dst, hidden_src,
                                  static_cast<uint64_t>(rows) * hidden_bytes)) {
            }
            if (is_fp8) {
                const uint64_t scale_dst =
                    static_cast<uint64_t>(scale_ptrs[dst_rank]) +
                    static_cast<uint64_t>(dst_row + first) * scale_bytes;
                const uint64_t scale_src =
                    reinterpret_cast<uint64_t>(scale_staging) +
                    static_cast<uint64_t>(first) * scale_bytes;
                while (!handle.invoke(callback_id, scale_dst, scale_src,
                                      static_cast<uint64_t>(rows) * scale_bytes)) {
                }
            }
        }
        context->save_device_handle(task, handle);
    }
}

} // namespace

void launch_kiwi_sdma_pack(
    const void* input, const void* scales, const int* expert_send_dst_rank,
    const int* expert_send_dst_row, const int* expert_send_count,
    const int* expert_send_offset, const int* dispatched_token_idx,
    const int64_t* pool_ptrs, const int64_t* scale_ptrs, void* staging,
    size_t staging_rows, int hidden_bytes, int scale_bytes, int num_tasks,
    bool is_fp8, void* kiwi_device_context, uint8_t callback_id,
    hipStream_t stream) {
    PRIMUS_TURBO_CHECK(hidden_bytes > 0 && hidden_bytes % sizeof(int4) == 0);
    PRIMUS_TURBO_CHECK(!is_fp8 || (scale_bytes > 0 && scale_bytes % sizeof(int4) == 0));
    if (num_tasks == 0) return;
    pack_and_invoke<<<num_tasks, 256, 0, stream>>>(
        static_cast<const uint8_t*>(input), static_cast<const uint8_t*>(scales),
        expert_send_dst_rank, expert_send_dst_row, expert_send_count,
        expert_send_offset, dispatched_token_idx, pool_ptrs, scale_ptrs,
        static_cast<uint8_t*>(staging), staging_rows, hidden_bytes, scale_bytes,
        is_fp8, static_cast<KiwiDeviceContext*>(kiwi_device_context), callback_id);
    PRIMUS_TURBO_CHECK_HIP(hipGetLastError());
}

} // namespace primus_turbo::mega_moe
