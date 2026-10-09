/***************************************************************************************************
 * Copyright (c) 2026, Advanced Micro Devices, Inc. All rights reserved.
 *
 * See LICENSE for license information.
 **************************************************************************************************/

#include "deep_ep.hpp"
#include "kiwi_sdma_state.hpp"

#include <ATen/cuda/CUDAContext.h>
#include <ATen/cuda/CUDADataType.h>
#include <chrono>
#include <torch/python.h>

#include "primus_turbo/deep_ep/api.h"
#include "primus_turbo/deep_ep/kiwi_sdma.h"

namespace primus_turbo::pytorch::deep_ep {

std::tuple<torch::Tensor, std::optional<torch::Tensor>, std::optional<torch::Tensor>,
           std::optional<torch::Tensor>, std::vector<int>, torch::Tensor, torch::Tensor,
           torch::Tensor, torch::Tensor, torch::Tensor, std::optional<EventHandle>>
Buffer::intranode_dispatch_sdma(
    const torch::Tensor &x, const std::optional<torch::Tensor> &x_scales,
    const std::optional<torch::Tensor> &topk_idx,
    const std::optional<torch::Tensor> &topk_weights,
    const std::optional<torch::Tensor> &num_tokens_per_rank,
    const torch::Tensor &is_token_in_rank,
    const std::optional<torch::Tensor> &num_tokens_per_expert,
    int cached_num_recv_tokens,
    const std::optional<torch::Tensor> &cached_rank_prefix_matrix,
    const std::optional<torch::Tensor> &cached_channel_prefix_matrix,
    int expert_alignment, int num_worst_tokens,
    const primus_turbo::deep_ep::Config &config,
    std::optional<EventHandle> &previous_event, bool async,
    bool allocate_on_comm_stream) {
    const bool cached_mode = cached_rank_prefix_matrix.has_value();
    PRIMUS_TURBO_CHECK(num_rdma_ranks == 1);
    PRIMUS_TURBO_CHECK(config.num_sms > 0 && config.num_sms % 2 == 0);
    PRIMUS_TURBO_CHECK(x.dim() == 2 && x.is_contiguous());
    const bool is_fp8 = x.element_size() == 1;
    PRIMUS_TURBO_CHECK(
        is_fp8 || x.scalar_type() == torch::kBFloat16 ||
        x.scalar_type() == torch::kFloat16);
    PRIMUS_TURBO_CHECK(x_scales.has_value() == is_fp8);
    PRIMUS_TURBO_CHECK((x.size(1) * x.element_size()) % sizeof(int4) == 0);
    PRIMUS_TURBO_CHECK(is_token_in_rank.scalar_type() == torch::kBool &&
                       is_token_in_rank.dim() == 2 &&
                       is_token_in_rank.is_contiguous());

    const int num_channels = config.num_sms / 2;
    const int num_tokens = static_cast<int>(x.size(0));
    const int hidden = static_cast<int>(x.size(1));
    const int hidden_bytes = hidden * static_cast<int>(x.element_size());
    int scale_bytes = 0;
    const float* x_scales_ptr = nullptr;
    if (x_scales) {
        PRIMUS_TURBO_CHECK(
            x_scales->scalar_type() == torch::kFloat32 &&
            x_scales->dim() == 2 && x_scales->is_contiguous() &&
            x_scales->size(0) == num_tokens);
        scale_bytes =
            static_cast<int>(x_scales->size(1) * x_scales->element_size());
        PRIMUS_TURBO_CHECK(scale_bytes % sizeof(int4) == 0);
        x_scales_ptr = x_scales->data_ptr<float>();
    }
    PRIMUS_TURBO_CHECK(is_token_in_rank.size(0) == num_tokens &&
                       is_token_in_rank.size(1) == num_ranks);

    int num_topk = 0;
    int num_experts = 0;
    const int64_t* topk_idx_ptr = nullptr;
    const float* topk_weights_ptr = nullptr;
    if (!cached_mode) {
        PRIMUS_TURBO_CHECK(num_tokens_per_rank.has_value() &&
                           num_tokens_per_expert.has_value() &&
                           topk_idx.has_value() && topk_weights.has_value());
        PRIMUS_TURBO_CHECK(num_tokens_per_rank->scalar_type() == torch::kInt32);
        PRIMUS_TURBO_CHECK(num_tokens_per_expert->scalar_type() == torch::kInt32);
        PRIMUS_TURBO_CHECK(topk_idx->scalar_type() == torch::kInt64 &&
                           topk_weights->scalar_type() == torch::kFloat32);
        PRIMUS_TURBO_CHECK(topk_idx->dim() == 2 && topk_idx->is_contiguous());
        PRIMUS_TURBO_CHECK(topk_weights->sizes() == topk_idx->sizes() &&
                           topk_weights->is_contiguous());
        num_topk = static_cast<int>(topk_idx->size(1));
        num_experts = static_cast<int>(num_tokens_per_expert->size(0));
        PRIMUS_TURBO_CHECK(num_experts > 0 && num_experts % num_ranks == 0);
        topk_idx_ptr = topk_idx->data_ptr<int64_t>();
        topk_weights_ptr = topk_weights->data_ptr<float>();
    } else {
        PRIMUS_TURBO_CHECK(cached_channel_prefix_matrix.has_value());
    }

    auto compute_stream = at::cuda::getCurrentCUDAStream();
    auto launch_stream = maybe_fork_stream(compute_stream, previous_event);
    const bool cross_stream_allocation =
        allocate_on_comm_stream && launch_stream.id() != compute_stream.id();
    if (cross_stream_allocation) {
        PRIMUS_TURBO_CHECK(previous_event.has_value() && async);
        at::cuda::setCurrentCUDAStream(launch_stream);
    }

    if (!kiwi_sdma_state)
        kiwi_sdma_state = std::make_unique<KiwiSdmaState>(device_id);
    kiwi_sdma_state->ensure(static_cast<size_t>(num_channels) * num_ranks);

    int num_recv_tokens = -1;
    torch::Tensor rank_prefix_matrix;
    torch::Tensor channel_prefix_matrix;
    std::vector<int> num_recv_tokens_per_expert_list;
    const int num_memset_int = num_channels * num_ranks * 4;
    if (cached_mode) {
        num_recv_tokens = cached_num_recv_tokens;
        rank_prefix_matrix = *cached_rank_prefix_matrix;
        channel_prefix_matrix = *cached_channel_prefix_matrix;
        primus_turbo::deep_ep::intranode::cached_notify_dispatch(
            rank_prefix_matrix.data_ptr<int>(), num_memset_int, buffer_ptrs_gpu,
            barrier_signal_ptrs_gpu, rank, num_ranks, launch_stream);
    } else {
        rank_prefix_matrix = torch::empty(
            {num_ranks, num_ranks},
            torch::TensorOptions().dtype(torch::kInt32).device(torch::kCUDA));
        channel_prefix_matrix = torch::empty(
            {num_ranks, num_channels},
            torch::TensorOptions().dtype(torch::kInt32).device(torch::kCUDA));
        *moe_recv_counter = -1;
        const int num_local_experts = num_experts / num_ranks;
        for (int i = 0; i < num_local_experts; ++i)
            moe_recv_expert_counter[i] = -1;
        primus_turbo::deep_ep::intranode::notify_dispatch(
            num_tokens_per_rank->data_ptr<int>(), moe_recv_counter_mapped, num_ranks,
            num_tokens_per_expert->data_ptr<int>(), moe_recv_expert_counter_mapped,
            num_experts, num_tokens, is_token_in_rank.data_ptr<bool>(),
            channel_prefix_matrix.data_ptr<int>(), rank_prefix_matrix.data_ptr<int>(),
            num_memset_int, expert_alignment, buffer_ptrs_gpu,
            barrier_signal_ptrs_gpu, rank, launch_stream, num_channels);
        if (num_worst_tokens > 0) {
            num_recv_tokens = num_worst_tokens;
        } else {
            const auto start = std::chrono::high_resolution_clock::now();
            for (;;) {
                num_recv_tokens = static_cast<int>(*moe_recv_counter);
                bool ready = num_recv_tokens >= 0;
                for (int i = 0; i < num_local_experts && ready; ++i)
                    ready = moe_recv_expert_counter[i] >= 0;
                if (ready) break;
                if (std::chrono::duration_cast<std::chrono::seconds>(
                        std::chrono::high_resolution_clock::now() - start).count() >
                    get_num_cpu_timeout_secs())
                    throw std::runtime_error("KIWI SDMA dispatch count timeout");
            }
            num_recv_tokens_per_expert_list.assign(
                moe_recv_expert_counter,
                moe_recv_expert_counter + num_local_experts);
        }
    }

    auto recv_x = torch::empty({num_recv_tokens, hidden}, x.options());
    std::optional<torch::Tensor> recv_x_scales;
    if (x_scales)
        recv_x_scales =
            torch::empty({num_recv_tokens, x_scales->size(1)}, x_scales->options());
    auto recv_src_idx = torch::empty(
        {num_recv_tokens},
        torch::TensorOptions().dtype(torch::kInt32).device(torch::kCUDA));
    auto recv_channel_prefix_matrix = torch::empty(
        {num_ranks, num_channels},
        torch::TensorOptions().dtype(torch::kInt32).device(torch::kCUDA));
    auto send_head = torch::empty(
        {num_tokens, num_ranks},
        torch::TensorOptions().dtype(torch::kInt32).device(torch::kCUDA));
    std::optional<torch::Tensor> recv_topk_idx;
    std::optional<torch::Tensor> recv_topk_weights;
    if (!cached_mode) {
        recv_topk_idx = torch::empty({num_recv_tokens, num_topk}, topk_idx->options());
        recv_topk_weights =
            torch::empty({num_recv_tokens, num_topk}, topk_weights->options());
    }

    const auto layout = primus_turbo::deep_ep::intranode::make_kiwi_sdma_layout(
        num_channels, num_ranks, hidden_bytes, scale_bytes, num_topk);
    PRIMUS_TURBO_CHECK(static_cast<int64_t>(layout.total_bytes) <= num_nvl_bytes);
    primus_turbo::deep_ep::intranode::kiwi_sdma_prepare(
        buffer_ptrs[rank], layout, hidden_bytes, scale_bytes, is_fp8, launch_stream);
    // All receive slots must be re-armed before any peer starts copying.
    primus_turbo::deep_ep::intranode::barrier(
        barrier_signal_ptrs_gpu, rank, num_ranks, launch_stream);
    primus_turbo::deep_ep::intranode::kiwi_sdma_dispatch(
        recv_x.data_ptr(),
        recv_x_scales ? recv_x_scales->data_ptr<float>() : nullptr,
        recv_src_idx.data_ptr<int>(),
        recv_topk_idx ? recv_topk_idx->data_ptr<int64_t>() : nullptr,
        recv_topk_weights ? recv_topk_weights->data_ptr<float>() : nullptr,
        recv_channel_prefix_matrix.data_ptr<int>(), send_head.data_ptr<int>(),
        x.data_ptr(), x_scales_ptr, topk_idx_ptr, topk_weights_ptr,
        is_token_in_rank.data_ptr<bool>(), rank_prefix_matrix.data_ptr<int>(),
        channel_prefix_matrix.data_ptr<int>(), num_tokens, num_worst_tokens,
        hidden_bytes, scale_bytes, num_topk, num_experts, is_fp8,
        buffer_ptrs_gpu, rank, num_ranks, num_channels, layout,
        kiwi_sdma_state->device_context(),
        kiwi_sdma_state->callback_id(), launch_stream);

    std::optional<EventHandle> event;
    if (async) {
        event = EventHandle(launch_stream);
        for (auto& tensor : {x, is_token_in_rank, rank_prefix_matrix,
                             channel_prefix_matrix, recv_x, recv_src_idx,
                             recv_channel_prefix_matrix, send_head}) {
            tensor.record_stream(launch_stream);
            if (cross_stream_allocation) tensor.record_stream(compute_stream);
        }
        for (auto& tensor : {x_scales, topk_idx, topk_weights, num_tokens_per_rank,
                             num_tokens_per_expert, cached_rank_prefix_matrix,
                             cached_channel_prefix_matrix, recv_topk_idx,
                             recv_topk_weights, recv_x_scales}) {
            if (tensor) tensor->record_stream(launch_stream);
            if (cross_stream_allocation && tensor)
                tensor->record_stream(compute_stream);
        }
    } else {
        maybe_join_stream(compute_stream);
    }
    if (cross_stream_allocation)
        at::cuda::setCurrentCUDAStream(compute_stream);

    return {recv_x, recv_x_scales, recv_topk_idx, recv_topk_weights,
            num_recv_tokens_per_expert_list, rank_prefix_matrix,
            channel_prefix_matrix, recv_channel_prefix_matrix, recv_src_idx,
            send_head, event};
}

} // namespace primus_turbo::pytorch::deep_ep
