/***************************************************************************************************
 * Copyright (c) 2026, Advanced Micro Devices, Inc. All rights reserved.
 *
 * See LICENSE for license information.
 **************************************************************************************************/

#include "kiwi_sdma_state.hpp"

#include "primus_turbo/common.h"
#include <algorithm>
#include <chrono>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <functional>
#include <pthread.h>
#include <sched.h>
#include <stdexcept>
#include <unordered_map>

namespace primus_turbo::pytorch::deep_ep {
namespace {

constexpr size_t kQueueCapacity = 1024;
constexpr size_t kMaxBatchCopies = 4096;

// KIWI chunks are at most 1 MiB, so copy thresholds up to that still route
// full chunks to SDMA; smaller copies (including PyTorch's small device-to-host
// reads) go to blit kernels.
constexpr long kMaxCopyThresholdKb = 1024;

bool env_threshold_ok(const char* name) {
    const char* value = std::getenv(name);
    if (value == nullptr || *value == '\0') return false;
    char* end = nullptr;
    const long kb = std::strtol(value, &end, 10);
    return *end == '\0' && kb >= 0 && kb <= kMaxCopyThresholdKb;
}

double now_ms() {
    return std::chrono::duration<double, std::milli>(
               std::chrono::steady_clock::now().time_since_epoch())
        .count();
}

} // namespace

KiwiSdmaState::KiwiSdmaState(int device_id) : device_id_(device_id) {
    if (!env_threshold_ok("ROC_P2P_SDMA_SIZE") ||
        !env_threshold_ok("GPU_FORCE_BLIT_COPY_SIZE")) {
        throw std::runtime_error(
            "KIWI_SDMA requires ROC_P2P_SDMA_SIZE and GPU_FORCE_BLIT_COPY_SIZE to be set "
            "to at most 1024 (KB) before process launch");
    }
}

KiwiSdmaState::~KiwiSdmaState() {
    stop();
    if (diag_host_) (void)hipHostFree(diag_host_);
}

void KiwiSdmaState::ensure(size_t num_endpoints) {
    if (context_ && num_endpoints_ >= num_endpoints) {
        check_error();
        return;
    }
    stop();
    PRIMUS_TURBO_CHECK_HIP(hipSetDevice(device_id_));
    if (!diag_host_) {
        void* host = nullptr;
        PRIMUS_TURBO_CHECK_HIP(hipHostMalloc(&host, sizeof(*diag_host_),
                                             hipHostMallocMapped | hipHostMallocCoherent));
        std::memset(host, 0, sizeof(*diag_host_));
        diag_host_ = static_cast<primus_turbo::deep_ep::intranode::KiwiSdmaDiag*>(host);
        void* device = nullptr;
        PRIMUS_TURBO_CHECK_HIP(hipHostGetDevicePointer(&device, host, 0));
        diag_device_ = static_cast<primus_turbo::deep_ep::intranode::KiwiSdmaDiag*>(device);
    }
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

void* KiwiSdmaState::reserve_staging(size_t bytes) {
    check_error();
    if (bytes <= staging_bytes_) return staging_;
    // Resizing is rare (shape change). Drain the current copy stream before
    // releasing storage that an outstanding batched copy may still reference.
    if (copy_stream_) PRIMUS_TURBO_CHECK_HIP(hipStreamSynchronize(copy_stream_));
    if (staging_) PRIMUS_TURBO_CHECK_HIP(hipFree(staging_));
    PRIMUS_TURBO_CHECK_HIP(hipMalloc(&staging_, bytes));
    staging_bytes_ = bytes;
    return staging_;
}

void KiwiSdmaState::flush() {
    if (dsts_.empty()) return;
    for (size_t offset = 0; offset < dsts_.size(); offset += kMaxBatchCopies) {
        const size_t count = std::min(kMaxBatchCopies, dsts_.size() - offset);
        size_t fail_index = 0;
        const double call_start = profile_.enabled ? now_ms() : 0;
        hipError_t status = hipMemcpyBatchAsync(
            dsts_.data() + offset, srcs_.data() + offset, sizes_.data() + offset,
            count, nullptr, nullptr, 0, &fail_index, copy_stream_);
        if (profile_.enabled) {
            const double call_ms = now_ms() - call_start;
            profile_.api_ms += call_ms;
            profile_.max_call_us = std::max(profile_.max_call_us, call_ms * 1e3);
            ++profile_.calls;
            profile_.copies += count;
            profile_.max_batch = std::max(profile_.max_batch, count);
            for (size_t i = offset; i < offset + count; ++i) profile_.bytes += sizes_[i];
        }
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
        const char* profile_env = std::getenv("KIWI_SDMA_PROFILE");
        profile_ = ProxyProfile{};
        profile_.enabled = profile_env != nullptr && std::string(profile_env) == "1";
        profile_.window_start_ms = now_ms();
        ready_.store(true, std::memory_order_release);
        while (!stop_.load(std::memory_order_acquire)) {
            size_t progressed = 0;
            const double sweep_start = profile_.enabled ? now_ms() : 0;
            for (size_t endpoint = 0; endpoint < num_endpoints_; ++endpoint)
                progressed += context_->progress(endpoint, -1);
            if (profile_.enabled) {
                profile_.progress_ms += now_ms() - sweep_start;
                ++profile_.sweeps;
                if (progressed == 0) ++profile_.idle_sweeps;
            }
            flush();
            if (profile_.enabled) report_profile(now_ms(), false);
            report_device_timeout();
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
        if (profile_.enabled) report_profile(now_ms(), true);
    } catch (const std::exception& error) {
        record_error(error.what());
        ready_.store(true, std::memory_order_release);
    }
}

void KiwiSdmaState::report_device_timeout() {
    using primus_turbo::deep_ep::intranode::KiwiSdmaDiag;
    if (diag_reported_ || diag_host_ == nullptr) return;
    const int kind = *static_cast<volatile int*>(&diag_host_->kind);
    if (kind <= 0) return;
    std::atomic_thread_fence(std::memory_order_acquire);
    diag_reported_ = true;
    static const char* const kNames[] = {"none", "receiver channel-prefix wait",
                                         "receiver payload wait", "sender KIWI invoke wait",
                                         "input holds sentinel", "non-finite scale",
                                         "sender found fewer rows than promised"};
    const KiwiSdmaDiag d = *diag_host_;
    std::fprintf(stderr,
                 "[KIWI_SDMA_FAILURE] device=%d %s: rank=%d peer=%d row=%d observed=0x%x "
                 "value=%llu progress=%d/%d\n",
                 device_id_, kind < 7 ? kNames[kind] : "unknown", d.rank, d.peer, d.row,
                 d.observed, static_cast<unsigned long long>(d.value), d.progress, d.total);
    std::fflush(stderr);
}

void KiwiSdmaState::report_profile(double now, bool force) {
    const double window_ms = now - profile_.window_start_ms;
    if (!force && window_ms < 1000.0) return;
    // A stream that stays busy with no new copies means submitted copies are
    // not completing, as opposed to the GPU senders not producing them.
    const bool stream_busy = copy_stream_ && hipStreamQuery(copy_stream_) == hipErrorNotReady;
    if (profile_.copies > 0 || stream_busy || force) {
        std::fprintf(stderr, "[KIWI_SDMA_PROFILE] device=%d copy_stream_busy=%d\n", device_id_,
                     stream_busy ? 1 : 0);
        // api_ms is host time blocked inside hipMemcpyBatchAsync; progress_ms is
        // time draining the KIWI queues. Whatever remains of the window is idle
        // polling, i.e. waiting on GPU senders, receivers, ACKs, or SDMA.
        std::fprintf(stderr,
                     "[KIWI_SDMA_PROFILE] device=%d window=%.1f ms api=%.3f ms "
                     "(%.1f%%) progress=%.3f ms calls=%zu copies=%zu max_batch=%zu "
                     "avg_batch=%.1f max_call=%.1f us per_copy_api=%.2f us "
                     "bytes=%.1f MiB sweeps=%zu idle_sweeps=%zu\n",
                     device_id_, window_ms, profile_.api_ms,
                     window_ms > 0 ? 100.0 * profile_.api_ms / window_ms : 0.0,
                     profile_.progress_ms, profile_.calls, profile_.copies,
                     profile_.max_batch,
                     profile_.calls ? static_cast<double>(profile_.copies) / profile_.calls
                                    : 0.0,
                     profile_.max_call_us,
                     profile_.copies ? profile_.api_ms * 1e3 / profile_.copies : 0.0,
                     static_cast<double>(profile_.bytes) / (1 << 20), profile_.sweeps,
                     profile_.idle_sweeps);
    }
    const bool enabled = profile_.enabled;
    profile_ = ProxyProfile{};
    profile_.enabled = enabled;
    profile_.window_start_ms = now;
}

void KiwiSdmaState::stop() {
    stop_.store(true, std::memory_order_release);
    if (proxy_thread_.joinable()) proxy_thread_.join();
    if (copy_stream_) {
        (void)hipStreamDestroy(copy_stream_);
        copy_stream_ = nullptr;
    }
    context_.reset();
    if (staging_) {
        (void)hipFree(staging_);
        staging_ = nullptr;
        staging_bytes_ = 0;
    }
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
    // The proxy stops on the first error and a waiting dispatch kernel can only
    // time out, so report it now rather than on the next host call.
    std::fprintf(stderr, "[KIWI_SDMA_PROXY_ERROR] device=%d %s\n", device_id_, message.c_str());
    std::fflush(stderr);
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

std::shared_ptr<KiwiSdmaState> get_kiwi_sdma_state(int device_id) {
    static std::mutex mutex;
    static std::unordered_map<int, std::shared_ptr<KiwiSdmaState>> states;
    std::lock_guard<std::mutex> lock(mutex);
    auto& state = states[device_id];
    if (!state) state = std::make_shared<KiwiSdmaState>(device_id);
    return state;
}

} // namespace primus_turbo::pytorch::deep_ep
