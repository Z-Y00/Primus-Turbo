/***************************************************************************************************
 * Copyright (c) 2026, Advanced Micro Devices, Inc. All rights reserved.
 *
 * See LICENSE for license information.
 **************************************************************************************************/

#pragma once

#include <kiwi/invoke/invoke.hpp>

#include "primus_turbo/deep_ep/kiwi_sdma.h"

#include <atomic>
#include <cstdint>
#include <memory>
#include <mutex>
#include <string>
#include <thread>
#include <utility>
#include <vector>

namespace primus_turbo::pytorch::deep_ep {

class KiwiSdmaState {
public:
    explicit KiwiSdmaState(int device_id);
    ~KiwiSdmaState();

    KiwiSdmaState(const KiwiSdmaState&) = delete;
    KiwiSdmaState& operator=(const KiwiSdmaState&) = delete;

    void ensure(size_t num_endpoints);
    void* reserve_staging(size_t bytes);
    void stop();
    void check_error() const;

    void* device_context() const;
    uint8_t callback_id() const { return callback_id_; }
    // flag(dst, value): writes value to dst on the copy stream after every copy
    // posted before the flag.
    uint8_t flag_callback_id() const { return flag_callback_id_; }
    primus_turbo::deep_ep::intranode::KiwiSdmaDiag* diag() const { return diag_device_; }

private:
    struct ProxyProfile {
        bool enabled = false;
        double window_start_ms = 0;
        double progress_ms = 0;
        double api_ms = 0;
        double max_call_us = 0;
        size_t sweeps = 0;
        size_t idle_sweeps = 0;
        size_t calls = 0;
        size_t copies = 0;
        size_t max_batch = 0;
        size_t bytes = 0;
    };

    void proxy_loop();
    void flush();
    void flush_copies();
    void report_profile(double now_ms, bool force);
    void report_device_timeout();
    void record_error(const std::string& message);

    int device_id_;
    size_t num_endpoints_ = 0;
    std::unique_ptr<kiwi::invoke::Context<>> context_;
    uint8_t callback_id_ = 0;
    uint8_t flag_callback_id_ = 0;
    hipStream_t copy_stream_ = nullptr;
    std::thread proxy_thread_;
    std::atomic<bool> stop_{false};
    std::atomic<bool> ready_{false};
    std::atomic<bool> failed_{false};
    mutable std::mutex error_mutex_;
    std::string error_message_;
    std::vector<void*> dsts_;
    std::vector<void*> srcs_;
    std::vector<size_t> sizes_;
    // Flags seen in the current sweep, and flags ready to issue. A flag waits
    // one full sweep so every copy posted before it on another endpoint has
    // been drained and submitted first.
    std::vector<std::pair<uint64_t*, uint64_t>> new_flags_;
    std::vector<std::pair<uint64_t*, uint64_t>> ready_flags_;
    void* staging_ = nullptr;
    size_t staging_bytes_ = 0;
    ProxyProfile profile_;
    primus_turbo::deep_ep::intranode::KiwiSdmaDiag* diag_host_ = nullptr;
    primus_turbo::deep_ep::intranode::KiwiSdmaDiag* diag_device_ = nullptr;
    bool diag_reported_ = false;
};

// Process-wide ownership prevents one application object from tearing down a
// per-device proxy while another (for example MegaMoE) still uses it.
std::shared_ptr<KiwiSdmaState> get_kiwi_sdma_state(int device_id);

} // namespace primus_turbo::pytorch::deep_ep
