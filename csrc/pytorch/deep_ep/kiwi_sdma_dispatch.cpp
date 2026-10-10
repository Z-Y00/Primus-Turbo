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
#include <cstdlib>
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
    const primus_turbo::deep_ep::Config &config, int64_t turbo_nvl_bytes,
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
        kiwi_sdma_state = get_kiwi_sdma_state(device_id);
    kiwi_sdma_state->ensure(static_cast<size_t>(num_ranks) * num_channels);

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

    PRIMUS_TURBO_CHECK(turbo_nvl_bytes >= 0 && turbo_nvl_bytes <= num_nvl_bytes);
    // 0 (default): one SDMA descriptor per destination. Positive: each channel
    // copies runs of at most this many bytes. Must match on every rank.
    size_t chunk_bytes = 0;
    if (const char* value = std::getenv("PRIMUS_TURBO_KIWI_SDMA_CHUNK_BYTES"))
        chunk_bytes = static_cast<size_t>(std::strtoull(value, nullptr, 10));
    const auto layout = primus_turbo::deep_ep::intranode::make_kiwi_sdma_layout(
        num_channels, num_ranks, hidden_bytes, scale_bytes, num_topk,
        static_cast<size_t>(turbo_nvl_bytes), static_cast<size_t>(num_nvl_bytes), chunk_bytes);
    if (static_cast<size_t>(num_recv_tokens) > layout.capacity_rows) {
        throw std::runtime_error(
            "KIWI_SDMA receive region holds " + std::to_string(layout.capacity_rows) +
            " rows but this dispatch receives " + std::to_string(num_recv_tokens) +
            "; size the buffer with deep_ep.get_kiwi_sdma_nvl_buffer_size_hint()");
    }
    // Rows for peer p are staged at [p * num_tokens, (p + 1) * num_tokens).
    void* staging = kiwi_sdma_state->reserve_staging(
        std::max<size_t>(1, static_cast<size_t>(num_ranks) * num_tokens) *
        layout.record_stride);
    const uint64_t epoch = ++kiwi_sdma_epoch;
    const bool reset_flags = layout.flag_offset != kiwi_sdma_flag_offset;
    kiwi_sdma_flag_offset = layout.flag_offset;
    primus_turbo::deep_ep::intranode::kiwi_sdma_prepare(
        buffer_ptrs_gpu, rank_prefix_matrix.data_ptr<int>(), rank, layout, num_ranks,
        reset_flags, launch_stream);
    // Every rank must publish its row bases before any peer starts sending.
    primus_turbo::deep_ep::intranode::barrier(
        barrier_signal_ptrs_gpu, rank, num_ranks, launch_stream);
    void* recv_scales_ptr = recv_x_scales ? recv_x_scales->data_ptr() : nullptr;
    int64_t* recv_topk_idx_ptr = recv_topk_idx ? recv_topk_idx->data_ptr<int64_t>() : nullptr;
    float* recv_topk_weights_ptr =
        recv_topk_weights ? recv_topk_weights->data_ptr<float>() : nullptr;
    primus_turbo::deep_ep::intranode::kiwi_sdma_send(
        recv_x.data_ptr(), static_cast<float*>(recv_scales_ptr), recv_src_idx.data_ptr<int>(),
        recv_topk_idx_ptr, recv_topk_weights_ptr, recv_channel_prefix_matrix.data_ptr<int>(),
        send_head.data_ptr<int>(), x.data_ptr(), x_scales_ptr, topk_idx_ptr, topk_weights_ptr,
        is_token_in_rank.data_ptr<bool>(), channel_prefix_matrix.data_ptr<int>(), num_tokens,
        num_worst_tokens, hidden_bytes, scale_bytes, num_topk, num_experts, buffer_ptrs_gpu,
        staging, rank, num_ranks, num_channels, layout, epoch,
        kiwi_sdma_state->device_context(), kiwi_sdma_state->callback_id(),
        kiwi_sdma_state->flag_callback_id(), kiwi_sdma_state->diag(), launch_stream);
    primus_turbo::deep_ep::intranode::kiwi_sdma_receive(
        recv_x.data_ptr(), static_cast<float*>(recv_scales_ptr), recv_src_idx.data_ptr<int>(),
        recv_topk_idx_ptr, recv_topk_weights_ptr, recv_channel_prefix_matrix.data_ptr<int>(),
        rank_prefix_matrix.data_ptr<int>(), hidden_bytes, scale_bytes, num_topk,
        buffer_ptrs_gpu, rank, num_ranks, num_channels, layout, epoch,
        kiwi_sdma_state->diag(), launch_stream);

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
