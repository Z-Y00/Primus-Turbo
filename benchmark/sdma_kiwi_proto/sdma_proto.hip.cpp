// SDMA transfer prototype for DeepEP / Mega MoE: GPU-initiated copies through
// KIWI invoke and hipMemcpyBatchAsync, with a bf16 signaling-NaN sentinel as
// the receive-side readiness signal.
//
// One process drives a source and a destination GPU with peer access.
//
//   --mode bw      Host-issued src->dst bandwidth per chunk size:
//                  batch  : one hipMemcpyBatchAsync of total/chunk copies
//                  nocu   : one hipMemcpyAsync(hipMemcpyDeviceToDeviceNoCU) per chunk
//                  kernel : CU push kernel (peer stores), the current DeepEP/Mega MoE path
//                  --busy fills every CU of the source GPU during the timed copy, so a
//                  copy that needs CUs (a blit kernel) stalls while SDMA does not.
//   --mode invoke  GPU-initiated rounds. A one-wavefront sender kernel invokes
//                  copy(dst, src, chunk, count) per round; the proxy thread expands it
//                  into count batch entries and issues one hipMemcpyBatchAsync per
//                  progress() pass. The receiver kernel either spins loading the round
//                  into LDS until no sentinel is left (--signal sentinel), verifies it
//                  and re-arms the buffer, or waits for an 8-byte flag copied after the
//                  batch on the same stream (--signal flag) and then loads it. The last
//                  receiver block of a round acks it in source-GPU memory. With
//                  --slots 1 the sender times each round trip; with more slots it times
//                  the whole run for throughput.

#include <kiwi/invoke/invoke.hpp>

#include <hip/hip_runtime.h>

#include <algorithm>
#include <atomic>
#include <chrono>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <functional>
#include <sched.h>
#include <stdexcept>
#include <string>
#include <thread>
#include <vector>

#define CHECK(call)                                                                    \
    do {                                                                               \
        hipError_t err_ = (call);                                                      \
        if (err_ != hipSuccess) {                                                      \
            std::fprintf(stderr, "%s:%d %s: %s\n", __FILE__, __LINE__, #call,          \
                         hipGetErrorString(err_));                                     \
            std::exit(1);                                                              \
        }                                                                              \
    } while (0)

namespace {

// A bf16 signaling NaN. Arithmetic only produces quiet NaNs, so payload never
// holds this exact pattern; readiness compares bits, not isnan().
constexpr uint16_t kSentinel = 0x7F81;
constexpr hipMemcpyKind kDeviceToDeviceNoCU = static_cast<hipMemcpyKind>(1024);
constexpr int kRecvThreads = 256;
constexpr int kTileVectors = 4 * kRecvThreads;  // 16 KB of uint4 per LDS tile
constexpr size_t kTileBytes = kTileVectors * 16;
constexpr uint64_t kSpinTimeoutTicks = 100ull * 1000 * 1000 * 10;  // 10 s at 100 MHz
// HIP 7.15 (rocm/primus:v26.7) faults in __amd_rocclr_copyBufferBatch above
// 4096 copies per call; 16384 x 4 KB reproduces it.
constexpr size_t kMaxBatchCopies = 4096;

void memcpy_batch(void** dsts, void** srcs, size_t* sizes, size_t count, hipStream_t stream) {
    for (size_t off = 0; off < count; off += kMaxBatchCopies) {
        size_t fail = 0;
        CHECK(hipMemcpyBatchAsync(dsts + off, srcs + off, sizes + off,
                                  std::min(kMaxBatchCopies, count - off), nullptr, nullptr, 0,
                                  &fail, stream));
    }
}

using v4u = unsigned __attribute__((ext_vector_type(4)));

struct Args {
    std::string mode = "bw";
    int src = 0;
    int dst = 1;
    std::vector<size_t> chunks{4096, 16384, 65536, 262144, 1 << 20, 4 << 20};
    std::string methods = "batch,nocu,kernel";
    size_t total = 256u << 20;
    int iters = 10;
    bool busy = false;
    int kernel_blocks = 64;
    size_t round_bytes = 4u << 20;
    int rounds = 200;
    int warmup = 20;
    int slots = 1;
    std::string signal = "sentinel";
    int recv_blocks = 64;
    int proxy_core = -1;
};

std::vector<size_t> parse_sizes(const std::string& text) {
    std::vector<size_t> out;
    size_t pos = 0;
    while (pos < text.size()) {
        size_t end = text.find(',', pos);
        if (end == std::string::npos) end = text.size();
        std::string item = text.substr(pos, end - pos);
        size_t mult = 1;
        if (!item.empty() && (item.back() == 'K' || item.back() == 'k')) mult = 1 << 10;
        if (!item.empty() && (item.back() == 'M' || item.back() == 'm')) mult = 1 << 20;
        if (mult != 1) item.pop_back();
        out.push_back(std::stoull(item) * mult);
        pos = end + 1;
    }
    return out;
}

Args parse_args(int argc, char** argv) {
    Args a;
    for (int i = 1; i < argc; ++i) {
        std::string k = argv[i];
        auto next = [&]() -> std::string {
            if (i + 1 >= argc) throw std::invalid_argument("missing value for " + k);
            return argv[++i];
        };
        if (k == "--mode") a.mode = next();
        else if (k == "--src") a.src = std::stoi(next());
        else if (k == "--dst") a.dst = std::stoi(next());
        else if (k == "--chunks") a.chunks = parse_sizes(next());
        else if (k == "--methods") a.methods = next();
        else if (k == "--total") a.total = parse_sizes(next()).at(0);
        else if (k == "--iters") a.iters = std::stoi(next());
        else if (k == "--busy") a.busy = true;
        else if (k == "--kernel-blocks") a.kernel_blocks = std::stoi(next());
        else if (k == "--round-bytes") a.round_bytes = parse_sizes(next()).at(0);
        else if (k == "--rounds") a.rounds = std::stoi(next());
        else if (k == "--warmup") a.warmup = std::stoi(next());
        else if (k == "--slots") a.slots = std::stoi(next());
        else if (k == "--signal") a.signal = next();
        else if (k == "--recv-blocks") a.recv_blocks = std::stoi(next());
        else if (k == "--proxy-core") a.proxy_core = std::stoi(next());
        else throw std::invalid_argument("unknown option " + k);
    }
    if (a.mode != "bw" && a.mode != "invoke") throw std::invalid_argument("--mode bw|invoke");
    if (a.signal != "sentinel" && a.signal != "flag")
        throw std::invalid_argument("--signal sentinel|flag");
    return a;
}

bool has_method(const Args& a, const char* m) {
    return ("," + a.methods + ",").find(std::string(",") + m + ",") != std::string::npos;
}

// ---------------------------------------------------------------- device code

__device__ inline uint16_t payload_value(uint64_t element, int slot) {
    return static_cast<uint16_t>(0x3F80 | ((element * 7 + slot * 13) & 0x7F));
}

__device__ inline bool word_has_sentinel(unsigned w) {
    return (w & 0xFFFFu) == kSentinel || (w >> 16) == kSentinel;
}

__device__ inline bool has_sentinel(v4u v) {
    return word_has_sentinel(v.x) | word_has_sentinel(v.y) | word_has_sentinel(v.z) |
           word_has_sentinel(v.w);
}

// Four system-scope 16-byte loads in flight at once (SC0 SC1: miss every cache,
// so a peer or SDMA write to this memory is seen).
__device__ inline void load4_sys(const v4u* p0, const v4u* p1, const v4u* p2, const v4u* p3,
                                 v4u& a, v4u& b, v4u& c, v4u& d) {
    asm volatile(
        "global_load_dwordx4 %0, %4, off sc0 sc1\n\t"
        "global_load_dwordx4 %1, %5, off sc0 sc1\n\t"
        "global_load_dwordx4 %2, %6, off sc0 sc1\n\t"
        "global_load_dwordx4 %3, %7, off sc0 sc1\n\t"
        "s_waitcnt vmcnt(0)"
        : "=&v"(a), "=&v"(b), "=&v"(c), "=&v"(d)
        : "v"(p0), "v"(p1), "v"(p2), "v"(p3)
        : "memory");
}

__device__ inline uint64_t load_u64_sys(const uint64_t* p) {
    return __hip_atomic_load(p, __ATOMIC_RELAXED, __HIP_MEMORY_SCOPE_SYSTEM);
}

__global__ void fill_payload(uint16_t* data, uint64_t elements_per_slot, int slots) {
    uint64_t n = elements_per_slot * slots;
    for (uint64_t i = blockIdx.x * (uint64_t)blockDim.x + threadIdx.x; i < n;
         i += (uint64_t)gridDim.x * blockDim.x) {
        data[i] = payload_value(i % elements_per_slot, static_cast<int>(i / elements_per_slot));
    }
}

__global__ void push_kernel(v4u* dst, const v4u* src, uint64_t chunk_vectors, uint64_t chunks) {
    for (uint64_t c = blockIdx.x; c < chunks; c += gridDim.x) {
        const v4u* s = src + c * chunk_vectors;
        v4u* d = dst + c * chunk_vectors;
        for (uint64_t i = threadIdx.x; i < chunk_vectors; i += blockDim.x) {
            __builtin_nontemporal_store(s[i], &d[i]);
        }
    }
}

__global__ void busy_kernel(const volatile int* stop) {
    while (*stop == 0) {
        __builtin_amdgcn_s_sleep(8);
    }
}

__global__ void sender_kernel(kiwi::invoke::DeviceContext<>* ctx, uint8_t cb_copy,
                              uint8_t cb_flag, int use_flag, uint64_t dst_base,
                              uint64_t src_base, uint64_t round_bytes, uint64_t chunk,
                              int slots, int rounds, uint64_t flag_base, uint64_t round_values,
                              const uint64_t* acks, unsigned long long* round_ticks,
                              unsigned long long* span_ticks) {
    auto h = ctx->get_device_handle(0);
    auto wait_ack = [&](int round) {
        while (load_u64_sys(acks + round) == 0) {
        }
    };
    const unsigned long long start = wall_clock64();
    for (int r = 0; r < rounds; ++r) {
        if (r >= slots) wait_ack(r - slots);
        const unsigned long long t0 = wall_clock64();
        const uint64_t slot = r % slots;
        while (!h.invoke(cb_copy, dst_base + slot * round_bytes, src_base + slot * round_bytes,
                         chunk, round_bytes / chunk)) {
        }
        if (use_flag) {
            while (!h.invoke(cb_flag, flag_base + slot * 8, round_values + r * 8ull)) {
            }
        }
        if (slots == 1) {
            wait_ack(r);
            if (threadIdx.x == 0) round_ticks[r] = wall_clock64() - t0;
        }
    }
    for (int r = rounds > slots ? rounds - slots : 0; r < rounds; ++r) wait_ack(r);
    if (threadIdx.x == 0) *span_ticks = wall_clock64() - start;
    ctx->save_device_handle(0, h);
}

template <bool kSentinelSignal>
__global__ void __launch_bounds__(kRecvThreads)
receiver_kernel(v4u* data, uint64_t round_bytes, int slots, int rounds, const uint64_t* flags,
                unsigned* done, uint64_t* peer_acks, unsigned* errors) {
    __shared__ v4u tile[kTileVectors];
    const uint64_t round_vectors = round_bytes / 16;
    const uint64_t tiles = round_bytes / kTileBytes;
    const int tid = threadIdx.x;
    for (int r = 0; r < rounds; ++r) {
        const int slot = r % slots;
        v4u* base = data + slot * round_vectors;
        if (!kSentinelSignal) {
            if (tid == 0) {
                const unsigned long long t0 = wall_clock64();
                while (load_u64_sys(flags + slot) < static_cast<uint64_t>(r + 1)) {
                    if (wall_clock64() - t0 > kSpinTimeoutTicks) {
                        atomicAdd(errors, 1u << 20);
                        break;
                    }
                }
            }
            __syncthreads();
        }
        unsigned bad = 0;
        for (uint64_t t = blockIdx.x; t < tiles; t += gridDim.x) {
            v4u* p = base + t * kTileVectors + tid;
            v4u a, b, c, d;
            const unsigned long long t0 = wall_clock64();
            for (;;) {
                load4_sys(p, p + kRecvThreads, p + 2 * kRecvThreads, p + 3 * kRecvThreads, a, b,
                          c, d);
                if (!kSentinelSignal) break;
                if (!(has_sentinel(a) | has_sentinel(b) | has_sentinel(c) | has_sentinel(d)))
                    break;
                if (wall_clock64() - t0 > kSpinTimeoutTicks) {
                    bad += 1u << 20;
                    break;
                }
            }
            tile[tid] = a;
            tile[tid + kRecvThreads] = b;
            tile[tid + 2 * kRecvThreads] = c;
            tile[tid + 3 * kRecvThreads] = d;
            __syncthreads();
            // Consume from LDS: every thread checks a vector another thread loaded.
            for (int k = 0; k < 4; ++k) {
                const int v = k * kRecvThreads + ((tid + 1) % kRecvThreads);
                const v4u got = tile[v];
                const uint64_t e0 = (t * kTileVectors + v) * 8;
                const unsigned words[4] = {got.x, got.y, got.z, got.w};
                for (int w = 0; w < 4; ++w) {
                    const unsigned expect =
                        payload_value(e0 + 2 * w, slot) |
                        (static_cast<unsigned>(payload_value(e0 + 2 * w + 1, slot)) << 16);
                    bad += words[w] != expect;
                }
            }
            if (kSentinelSignal) {
                const v4u s = {0x7F817F81u, 0x7F817F81u, 0x7F817F81u, 0x7F817F81u};
                p[0] = s;
                p[kRecvThreads] = s;
                p[2 * kRecvThreads] = s;
                p[3 * kRecvThreads] = s;
            }
            __syncthreads();
        }
        if (bad) atomicAdd(errors, bad);
        // Re-armed sentinels must be visible before the sender may reuse the slot.
        __threadfence_system();
        __syncthreads();
        if (tid == 0 && atomicAdd(done + r, 1u) == gridDim.x - 1) {
            __hip_atomic_store(peer_acks + r, uint64_t{1}, __ATOMIC_RELEASE,
                               __HIP_MEMORY_SCOPE_SYSTEM);
        }
    }
}

// ------------------------------------------------------------------ host code

double ticks_to_us(unsigned long long ticks, int device) {
    int khz = 0;
    CHECK(hipDeviceGetAttribute(&khz, hipDeviceAttributeWallClockRate, device));
    return ticks * 1e3 / khz;
}

void enable_peer(int a, int b) {
    int ok = 0;
    CHECK(hipDeviceCanAccessPeer(&ok, a, b));
    if (!ok) throw std::runtime_error("no peer access between GPUs");
    CHECK(hipSetDevice(a));
    hipError_t e = hipDeviceEnablePeerAccess(b, 0);
    if (e != hipSuccess && e != hipErrorPeerAccessAlreadyEnabled) CHECK(e);
    (void)hipGetLastError();
}

void run_bw(const Args& a) {
    CHECK(hipSetDevice(a.dst));
    void* dst = nullptr;
    CHECK(hipMalloc(&dst, a.total));
    CHECK(hipSetDevice(a.src));
    void* src = nullptr;
    CHECK(hipMalloc(&src, a.total));
    CHECK(hipMemset(src, 0x3c, a.total));
    hipStream_t stream, busy_stream;
    CHECK(hipStreamCreateWithFlags(&stream, hipStreamNonBlocking));
    CHECK(hipStreamCreateWithFlags(&busy_stream, hipStreamNonBlocking));
    hipEvent_t e0, e1;
    CHECK(hipEventCreate(&e0));
    CHECK(hipEventCreate(&e1));
    int* stop = nullptr;
    CHECK(hipHostMalloc(&stop, sizeof(int), hipHostMallocCoherent));
    int cus = 0;
    CHECK(hipDeviceGetAttribute(&cus, hipDeviceAttributeMultiprocessorCount, a.src));

    for (size_t chunk : a.chunks) {
        const size_t n = a.total / chunk;
        std::vector<void*> dsts(n), srcs(n);
        std::vector<size_t> sizes(n, chunk);
        for (size_t i = 0; i < n; ++i) {
            dsts[i] = static_cast<char*>(dst) + i * chunk;
            srcs[i] = static_cast<char*>(src) + i * chunk;
        }
        auto issue = [&](const std::string& method) {
            if (method == "batch") {
                memcpy_batch(dsts.data(), srcs.data(), sizes.data(), n, stream);
            } else if (method == "nocu") {
                for (size_t i = 0; i < n; ++i)
                    CHECK(hipMemcpyAsync(dsts[i], srcs[i], chunk, kDeviceToDeviceNoCU, stream));
            } else {
                push_kernel<<<a.kernel_blocks, 256, 0, stream>>>(
                    static_cast<v4u*>(dst), static_cast<const v4u*>(src), chunk / 16, n);
                CHECK(hipGetLastError());
            }
        };
        for (const char* method : {"batch", "nocu", "kernel"}) {
            if (!has_method(a, method)) continue;
            issue(method);
            CHECK(hipStreamSynchronize(stream));
            if (a.busy) {
                *stop = 0;
                busy_kernel<<<cus * 8, 1024, 0, busy_stream>>>(stop);
                CHECK(hipGetLastError());
                std::this_thread::sleep_for(std::chrono::milliseconds(20));
            }
            const auto host0 = std::chrono::steady_clock::now();
            CHECK(hipEventRecord(e0, stream));
            for (int it = 0; it < a.iters; ++it) issue(method);
            CHECK(hipEventRecord(e1, stream));
            const auto host1 = std::chrono::steady_clock::now();
            const auto deadline = host1 + std::chrono::seconds(20);
            bool stalled = false;
            while (hipEventQuery(e1) == hipErrorNotReady) {
                if (a.busy && std::chrono::steady_clock::now() > deadline) {
                    stalled = true;
                    break;
                }
                std::this_thread::yield();
            }
            if (a.busy) {
                *stop = 1;
                CHECK(hipStreamSynchronize(busy_stream));
            }
            CHECK(hipStreamSynchronize(stream));
            float ms = 0;
            CHECK(hipEventElapsedTime(&ms, e0, e1));
            const double issue_us =
                std::chrono::duration<double, std::micro>(host1 - host0).count() / a.iters;
            std::printf("result mode=bw method=%s chunk=%zu copies=%zu bytes=%zu busy=%d "
                        "gbps=%.2f issue_us=%.1f%s\n",
                        method, chunk, n, a.total, a.busy,
                        stalled ? 0.0 : a.total * a.iters / (ms * 1e-3) / 1e9, issue_us,
                        stalled ? " stalled=1" : "");
            std::fflush(stdout);
        }
    }
    CHECK(hipHostFree(stop));
    CHECK(hipFree(src));
    CHECK(hipSetDevice(a.dst));
    CHECK(hipFree(dst));
}

struct InvokeBuffers {
    void* src_data = nullptr;       // source GPU
    uint64_t* acks = nullptr;       // source GPU, uncached
    uint64_t* round_values = nullptr;
    unsigned long long* round_ticks = nullptr;
    unsigned long long* span_ticks = nullptr;
    void* dst_data = nullptr;       // destination GPU, uncached
    uint64_t* flags = nullptr;      // destination GPU, uncached
    unsigned* done = nullptr;
    unsigned* errors = nullptr;
};

void run_invoke(const Args& a) {
    if (a.round_bytes % kTileBytes != 0)
        throw std::invalid_argument("--round-bytes must be a multiple of 16 KB");
    const bool sentinel = a.signal == "sentinel";
    const int max_rounds = std::max(a.rounds, a.warmup);
    const size_t data_bytes = a.round_bytes * a.slots;
    InvokeBuffers b;

    CHECK(hipSetDevice(a.dst));
    CHECK(hipExtMallocWithFlags(&b.dst_data, data_bytes, hipDeviceMallocUncached));
    CHECK(hipExtMallocWithFlags(reinterpret_cast<void**>(&b.flags), a.slots * 8,
                                hipDeviceMallocUncached));
    CHECK(hipMalloc(&b.done, max_rounds * sizeof(unsigned)));
    CHECK(hipMalloc(&b.errors, sizeof(unsigned)));
    hipStream_t recv_stream;
    CHECK(hipStreamCreateWithFlags(&recv_stream, hipStreamNonBlocking));

    CHECK(hipSetDevice(a.src));
    CHECK(hipMalloc(&b.src_data, data_bytes));
    fill_payload<<<1024, 256>>>(static_cast<uint16_t*>(b.src_data), a.round_bytes / 2, a.slots);
    CHECK(hipGetLastError());
    CHECK(hipExtMallocWithFlags(reinterpret_cast<void**>(&b.acks), max_rounds * 8,
                                hipDeviceMallocUncached));
    CHECK(hipMalloc(&b.round_values, max_rounds * 8));
    std::vector<uint64_t> values(max_rounds);
    for (int r = 0; r < max_rounds; ++r) values[r] = r + 1;
    CHECK(hipMemcpy(b.round_values, values.data(), max_rounds * 8, hipMemcpyHostToDevice));
    CHECK(hipMalloc(&b.round_ticks, max_rounds * sizeof(unsigned long long)));
    CHECK(hipMalloc(&b.span_ticks, sizeof(unsigned long long)));
    hipStream_t send_stream;
    CHECK(hipStreamCreateWithFlags(&send_stream, hipStreamNonBlocking));
    CHECK(hipDeviceSynchronize());

    kiwi::invoke::Context<> ctx(1, 4096);
    hipStream_t copy_stream;
    CHECK(hipStreamCreateWithFlags(&copy_stream, hipStreamNonBlocking));
    std::vector<void*> dsts, srcs;
    std::vector<size_t> sizes;
    std::atomic<uint64_t> batches{0}, copies{0};
    auto flush = [&] {
        if (dsts.empty()) return;
        memcpy_batch(dsts.data(), srcs.data(), sizes.data(), dsts.size(), copy_stream);
        batches.fetch_add(1, std::memory_order_relaxed);
        copies.fetch_add(dsts.size(), std::memory_order_relaxed);
        dsts.clear();
        srcs.clear();
        sizes.clear();
    };
    const uint8_t cb_copy = ctx.register_callback(
        std::function<void(uint64_t, uint64_t, uint64_t, uint64_t)>(
            [&](uint64_t dst, uint64_t src, uint64_t chunk, uint64_t count) {
                for (uint64_t i = 0; i < count; ++i) {
                    dsts.push_back(reinterpret_cast<void*>(dst + i * chunk));
                    srcs.push_back(reinterpret_cast<void*>(src + i * chunk));
                    sizes.push_back(chunk);
                }
            }));
    const uint8_t cb_flag = ctx.register_callback(
        std::function<void(uint64_t, uint64_t)>([&](uint64_t dst, uint64_t src) {
            flush();
            CHECK(hipMemcpyAsync(reinterpret_cast<void*>(dst), reinterpret_cast<void*>(src), 8,
                                 kDeviceToDeviceNoCU, copy_stream));
        }));

    std::atomic<bool> stop{false};
    std::thread proxy([&] {
        if (a.proxy_core >= 0) {
            cpu_set_t set;
            CPU_ZERO(&set);
            CPU_SET(a.proxy_core, &set);
            sched_setaffinity(0, sizeof(set), &set);
        }
        CHECK(hipSetDevice(a.src));
        while (!stop.load(std::memory_order_acquire)) {
            ctx.progress(0);
            flush();
        }
        while (ctx.progress(0) != 0) {
        }
        flush();
    });

    for (size_t chunk : a.chunks) {
        if (a.round_bytes % chunk != 0) continue;
        for (int pass = 0; pass < 2; ++pass) {
            const int rounds = pass == 0 ? a.warmup : a.rounds;
            if (rounds == 0) continue;
            CHECK(hipSetDevice(a.dst));
            CHECK(hipMemsetD16(reinterpret_cast<hipDeviceptr_t>(b.dst_data), kSentinel,
                               data_bytes / 2));
            CHECK(hipMemset(b.flags, 0, a.slots * 8));
            CHECK(hipMemset(b.done, 0, max_rounds * sizeof(unsigned)));
            CHECK(hipMemset(b.errors, 0, sizeof(unsigned)));
            CHECK(hipDeviceSynchronize());
            CHECK(hipSetDevice(a.src));
            CHECK(hipMemset(b.acks, 0, max_rounds * 8));
            CHECK(hipDeviceSynchronize());
            batches.store(0);
            copies.store(0);

            CHECK(hipSetDevice(a.dst));
            if (sentinel) {
                receiver_kernel<true><<<a.recv_blocks, kRecvThreads, 0, recv_stream>>>(
                    static_cast<v4u*>(b.dst_data), a.round_bytes, a.slots, rounds, b.flags,
                    b.done, b.acks, b.errors);
            } else {
                receiver_kernel<false><<<a.recv_blocks, kRecvThreads, 0, recv_stream>>>(
                    static_cast<v4u*>(b.dst_data), a.round_bytes, a.slots, rounds, b.flags,
                    b.done, b.acks, b.errors);
            }
            CHECK(hipGetLastError());
            CHECK(hipSetDevice(a.src));
            sender_kernel<<<1, 64, 0, send_stream>>>(
                ctx.device_context(), cb_copy, cb_flag, sentinel ? 0 : 1,
                reinterpret_cast<uint64_t>(b.dst_data), reinterpret_cast<uint64_t>(b.src_data),
                a.round_bytes, chunk, a.slots, rounds, reinterpret_cast<uint64_t>(b.flags),
                reinterpret_cast<uint64_t>(b.round_values), b.acks, b.round_ticks,
                b.span_ticks);
            CHECK(hipGetLastError());
            CHECK(hipStreamSynchronize(send_stream));
            CHECK(hipSetDevice(a.dst));
            CHECK(hipStreamSynchronize(recv_stream));
            if (pass == 0) continue;

            unsigned errors = 0;
            CHECK(hipMemcpy(&errors, b.errors, sizeof(errors), hipMemcpyDeviceToHost));
            CHECK(hipSetDevice(a.src));
            unsigned long long span = 0;
            CHECK(hipMemcpy(&span, b.span_ticks, sizeof(span), hipMemcpyDeviceToHost));
            const double span_us = ticks_to_us(span, a.src);
            std::string lat;
            if (a.slots == 1) {
                std::vector<unsigned long long> ticks(rounds);
                CHECK(hipMemcpy(ticks.data(), b.round_ticks, rounds * sizeof(ticks[0]),
                                hipMemcpyDeviceToHost));
                std::sort(ticks.begin(), ticks.end());
                char buf[128];
                std::snprintf(buf, sizeof(buf), " rtt_us_p50=%.2f rtt_us_p99=%.2f",
                              ticks_to_us(ticks[rounds / 2], a.src),
                              ticks_to_us(ticks[std::min(rounds - 1, rounds * 99 / 100)], a.src));
                lat = buf;
            }
            std::printf("result mode=invoke signal=%s chunk=%zu round_bytes=%zu slots=%d "
                        "rounds=%d batches=%llu copies=%llu gbps=%.2f%s errors=%u\n",
                        a.signal.c_str(), chunk, a.round_bytes, a.slots, rounds,
                        (unsigned long long)batches.load(), (unsigned long long)copies.load(),
                        a.round_bytes * double(rounds) / (span_us * 1e-6) / 1e9, lat.c_str(),
                        errors);
            std::fflush(stdout);
        }
    }
    stop.store(true, std::memory_order_release);
    proxy.join();
    CHECK(hipStreamSynchronize(copy_stream));
}

}  // namespace

int main(int argc, char** argv) {
    try {
        const Args a = parse_args(argc, argv);
        enable_peer(a.src, a.dst);
        enable_peer(a.dst, a.src);
        hipDeviceProp_t prop;
        CHECK(hipGetDeviceProperties(&prop, a.src));
        std::printf("devices src=%d dst=%d arch=%s\n", a.src, a.dst, prop.gcnArchName);
        if (a.mode == "bw") run_bw(a);
        else run_invoke(a);
    } catch (const std::exception& e) {
        std::fprintf(stderr, "error: %s\n", e.what());
        return 1;
    }
    return 0;
}
