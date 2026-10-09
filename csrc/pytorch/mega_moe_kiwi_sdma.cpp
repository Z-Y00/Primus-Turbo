/***************************************************************************************************
 * Copyright (c) 2026, Advanced Micro Devices, Inc. All rights reserved.
 *
 * See LICENSE for license information.
 **************************************************************************************************/

#include "extensions.h"
#include "deep_ep/kiwi_sdma_state.hpp"

#include "primus_turbo/common.h"
#include "primus_turbo/mega_moe_kiwi_sdma.h"

namespace primus_turbo::pytorch {

void mega_moe_kiwi_sdma_dispatch(
    const at::Tensor& input, const c10::optional<at::Tensor>& scales,
    const at::Tensor& expert_send_dst_rank,
    const at::Tensor& expert_send_dst_row,
    const at::Tensor& expert_send_count,
    const at::Tensor& expert_send_offset,
    const at::Tensor& dispatched_token_idx,
    const at::Tensor& pool_ptrs,
    const c10::optional<at::Tensor>& scale_ptrs) {
    PRIMUS_TURBO_CHECK(input.is_cuda() && input.dim() == 2 && input.is_contiguous());
    PRIMUS_TURBO_CHECK(input.scalar_type() == at::kBFloat16 ||
                       input.scalar_type() == at::kHalf ||
                       input.element_size() == 1);
    const bool is_fp8 = input.element_size() == 1;
    PRIMUS_TURBO_CHECK(scales.has_value() == is_fp8);
    PRIMUS_TURBO_CHECK(scale_ptrs.has_value() == is_fp8);
    for (const auto* tensor : {&expert_send_dst_rank, &expert_send_dst_row,
                               &expert_send_count, &expert_send_offset,
                               &dispatched_token_idx}) {
        PRIMUS_TURBO_CHECK(tensor->is_cuda() && tensor->is_contiguous() &&
                           tensor->scalar_type() == at::kInt &&
                           tensor->get_device() == input.get_device());
    }
    PRIMUS_TURBO_CHECK(expert_send_dst_rank.numel() == expert_send_dst_row.numel() &&
                       expert_send_dst_rank.numel() == expert_send_count.numel() &&
                       expert_send_dst_rank.numel() == expert_send_offset.numel());
    PRIMUS_TURBO_CHECK(pool_ptrs.is_cuda() && pool_ptrs.is_contiguous() &&
                       pool_ptrs.scalar_type() == at::kLong &&
                       pool_ptrs.get_device() == input.get_device() &&
                       pool_ptrs.numel() > 0);

    const int hidden_bytes =
        static_cast<int>(input.size(1) * input.element_size());
    PRIMUS_TURBO_CHECK(hidden_bytes > 0 && hidden_bytes % 16 == 0);
    int scale_bytes = 0;
    const void* scales_data = nullptr;
    const int64_t* scale_ptr_data = nullptr;
    if (is_fp8) {
        PRIMUS_TURBO_CHECK(scales->is_cuda() && scales->dim() == 2 &&
                           scales->is_contiguous() && scales->size(0) == input.size(0) &&
                           scales->scalar_type() == at::kByte &&
                           scales->get_device() == input.get_device());
        PRIMUS_TURBO_CHECK(scale_ptrs->is_cuda() && scale_ptrs->is_contiguous() &&
                           scale_ptrs->scalar_type() == at::kLong &&
                           scale_ptrs->get_device() == input.get_device() &&
                           scale_ptrs->numel() == pool_ptrs.numel());
        scale_bytes = static_cast<int>(scales->size(1) * scales->element_size());
        PRIMUS_TURBO_CHECK(scale_bytes > 0 && scale_bytes % 16 == 0);
        scales_data = scales->data_ptr();
        scale_ptr_data = scale_ptrs->data_ptr<int64_t>();
    }

    const int device = input.get_device();
    const size_t num_tasks = static_cast<size_t>(expert_send_dst_rank.numel());
    if (num_tasks == 0) return;
    auto state = deep_ep::get_kiwi_sdma_state(device);
    state->ensure(num_tasks);
    const size_t staging_rows =
        static_cast<size_t>(dispatched_token_idx.numel());
    PRIMUS_TURBO_CHECK(staging_rows > 0);
    void* staging = state->reserve_staging(
        staging_rows * static_cast<size_t>(hidden_bytes + scale_bytes));
    auto stream = at::cuda::getCurrentCUDAStream(device);
    mega_moe::launch_kiwi_sdma_pack(
        input.data_ptr(), scales_data,
        expert_send_dst_rank.data_ptr<int>(),
        expert_send_dst_row.data_ptr<int>(),
        expert_send_count.data_ptr<int>(),
        expert_send_offset.data_ptr<int>(),
        dispatched_token_idx.data_ptr<int>(),
        pool_ptrs.data_ptr<int64_t>(), scale_ptr_data, staging, staging_rows,
        hidden_bytes, scale_bytes, static_cast<int>(num_tasks), is_fp8,
        state->device_context(), state->callback_id(), stream);
    state->check_error();
}

} // namespace primus_turbo::pytorch
