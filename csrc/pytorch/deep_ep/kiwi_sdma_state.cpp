/***************************************************************************************************
 * Copyright (c) 2026, Advanced Micro Devices, Inc. All rights reserved.
 *
 * See LICENSE for license information.
 **************************************************************************************************/

#include "kiwi_sdma_state.hpp"

#include "primus_turbo/common.h"
#include <algorithm>
#include <chrono>
#include <cstdlib>
#include <functional>
#include <pthread.h>
#include <sched.h>
#include <stdexcept>

namespace primus_turbo::pytorch::deep_ep {
namespace {

constexpr size_t kQueueCapacity = 1024;
constexpr size_t kMaxBatchCopies = 4096;

bool env_is_zero(const char* name) {
    const char* value = std::getenv(name);
    return value != nullptr && std::string(value) == "0";
}

} // namespace

KiwiSdmaState::KiwiSdmaState(int device_id) : device_id_(device_id) {
    if (!env_is_zero("ROC_P2P_SDMA_SIZE") ||
        !env_is_zero("GPU_FORCE_BLIT_COPY_SIZE")) {
        throw std::runtime_error(
            "KIWI_SDMA requires ROC_P2P_SDMA_SIZE=0 and "
            "GPU_FORCE_BLIT_COPY_SIZE=0 before process launch");
    }
}

KiwiSdmaState::~KiwiSdmaState() {
    stop();
}

void KiwiSdmaState::ensure(size_t num_endpoints) {
    if (context_ && num_endpoints_ == num_endpoints) {
        check_error();
        return;
    }
    stop();
    PRIMUS_TURBO_CHECK_HIP(hipSetDevice(device_id_));
    context_ = std::make_unique<kiwi::invoke::Context<>>(num_endpoints, kQueueCapacity);
    callback_id_ = context_->register_callback(
        std::function<void(uint64_t, uint64_t, uint64_t)>(
            [this](uint64_t dst, uint64_t src, uint64_t bytes) {
                if (bytes == 0) {
                    record_error("KIWI SDMA callback received a zero-byte copy");
                    return;
                }
                dsts_.push_back(reinterpret_cast<void*>(dst));
                srcs_.push_back(reinterpret_cast<void*>(src));
                sizes_.push_back(static_cast<size_t>(bytes));
            }));
    PRIMUS_TURBO_CHECK_HIP(
        hipStreamCreateWithFlags(&copy_stream_, hipStreamNonBlocking));
    num_endpoints_ = num_endpoints;
    stop_.store(false, std::memory_order_release);
    ready_.store(false, std::memory_order_release);
    failed_.store(false, std::memory_order_release);
    proxy_thread_ = std::thread(&KiwiSdmaState::proxy_loop, this);
    while (!ready_.load(std::memory_order_acquire) &&
           !failed_.load(std::memory_order_acquire))
        std::this_thread::yield();
    check_error();
}

void KiwiSdmaState::flush() {
    if (dsts_.empty()) return;
    for (size_t offset = 0; offset < dsts_.size(); offset += kMaxBatchCopies) {
        const size_t count = std::min(kMaxBatchCopies, dsts_.size() - offset);
        size_t fail_index = 0;
        hipError_t status = hipMemcpyBatchAsync(
            dsts_.data() + offset, srcs_.data() + offset, sizes_.data() + offset,
            count, nullptr, nullptr, 0, &fail_index, copy_stream_);
        if (status != hipSuccess) {
            record_error(
                "hipMemcpyBatchAsync failed at batch index " +
                std::to_string(offset + fail_index) + ": " +
                hipGetErrorString(status));
            break;
        }
    }
    dsts_.clear();
    srcs_.clear();
    sizes_.clear();
}

void KiwiSdmaState::proxy_loop() {
    try {
        PRIMUS_TURBO_CHECK_HIP(hipSetDevice(device_id_));
        if (const char* value = std::getenv("KIWI_SDMA_PROXY_CPU")) {
            const int cpu = std::stoi(value);
            if (cpu < 0 || cpu >= CPU_SETSIZE)
                throw std::runtime_error("KIWI_SDMA_PROXY_CPU is outside the CPU affinity range");
            cpu_set_t set;
            CPU_ZERO(&set);
            CPU_SET(cpu, &set);
            const int status = pthread_setaffinity_np(pthread_self(), sizeof(set), &set);
            if (status != 0)
                throw std::runtime_error(
                    "failed to apply KIWI_SDMA_PROXY_CPU affinity: " +
                    std::to_string(status));
        }
        ready_.store(true, std::memory_order_release);
        while (!stop_.load(std::memory_order_acquire)) {
            size_t progressed = 0;
            for (size_t endpoint = 0; endpoint < num_endpoints_; ++endpoint)
                progressed += context_->progress(endpoint, -1);
            flush();
            if (progressed == 0) std::this_thread::yield();
            if (failed_.load(std::memory_order_acquire)) break;
        }
        for (;;) {
            size_t progressed = 0;
            for (size_t endpoint = 0; endpoint < num_endpoints_; ++endpoint)
                progressed += context_->progress(endpoint, -1);
            flush();
            if (progressed == 0) break;
        }
        if (copy_stream_) {
            hipError_t status = hipStreamSynchronize(copy_stream_);
            if (status != hipSuccess)
                record_error(std::string("KIWI SDMA copy stream failed: ") +
                             hipGetErrorString(status));
        }
    } catch (const std::exception& error) {
        record_error(error.what());
        ready_.store(true, std::memory_order_release);
    }
}

void KiwiSdmaState::stop() {
    stop_.store(true, std::memory_order_release);
    if (proxy_thread_.joinable()) proxy_thread_.join();
    if (copy_stream_) {
        (void)hipStreamDestroy(copy_stream_);
        copy_stream_ = nullptr;
    }
    context_.reset();
    num_endpoints_ = 0;
    dsts_.clear();
    srcs_.clear();
    sizes_.clear();
}

void KiwiSdmaState::record_error(const std::string& message) {
    {
        std::lock_guard<std::mutex> lock(error_mutex_);
        if (error_message_.empty()) error_message_ = message;
    }
    failed_.store(true, std::memory_order_release);
}

void KiwiSdmaState::check_error() const {
    if (!failed_.load(std::memory_order_acquire)) return;
    std::lock_guard<std::mutex> lock(error_mutex_);
    throw std::runtime_error(
        error_message_.empty() ? "KIWI SDMA proxy failed" : error_message_);
}

void* KiwiSdmaState::device_context() const {
    return context_ ? context_->device_context() : nullptr;
}

} // namespace primus_turbo::pytorch::deep_ep
