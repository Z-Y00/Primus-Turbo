/***************************************************************************************************
 * Copyright (c) 2026, Advanced Micro Devices, Inc. All rights reserved.
 *
 * See LICENSE for license information.
 **************************************************************************************************/

#pragma once

#include <kiwi/invoke/invoke.hpp>

#include <atomic>
#include <cstdint>
#include <memory>
#include <mutex>
#include <string>
#include <thread>
#include <vector>

namespace primus_turbo::pytorch::deep_ep {

class KiwiSdmaState {
public:
    explicit KiwiSdmaState(int device_id);
    ~KiwiSdmaState();

    KiwiSdmaState(const KiwiSdmaState&) = delete;
    KiwiSdmaState& operator=(const KiwiSdmaState&) = delete;

    void ensure(size_t num_endpoints);
    void stop();
    void check_error() const;

    void* device_context() const;
    uint8_t callback_id() const { return callback_id_; }

private:
    void proxy_loop();
    void flush();
    void record_error(const std::string& message);

    int device_id_;
    size_t num_endpoints_ = 0;
    std::unique_ptr<kiwi::invoke::Context<>> context_;
    uint8_t callback_id_ = 0;
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
};

} // namespace primus_turbo::pytorch::deep_ep
