// Reproducer: peer hipMemcpyBatchAsync copies on one stream stop completing
// while a device-to-host copy on another stream waits behind a running kernel.
//
// One process per GPU. Each iteration, every rank:
//   1. arms its receive buffer with a sentinel and joins a cross-process barrier;
//   2. main thread: launches a kernel on stream S that spins until every chunk
//      from every peer has landed (or a timeout expires);
//   3. proxy thread: issues the peer copies with hipMemcpyBatchAsync on a
//      separate non-blocking stream C, one batch every --batch-interval-us,
//      descriptors interleaved across destination ranks;
//   4. main thread, with --block-op d2h: --d2h-delay-us after the launch,
//      enqueues a small device-to-host hipMemcpyAsync on S and waits for it.
//      That copy can only run after the kernel, which needs the peer copies.
//
// This is the pattern of the KIWI SDMA dispatch inside a PyTorch MoE layer:
// the proxy submits copies while Python already waits in a .to() copy queued
// behind the dispatch kernel. With --block-op none the copies complete in
// milliseconds. If the runtime orders the S copy ahead of later C copies on a
// shared SDMA queue, copies issued after it never complete, the kernel times
// out, and the drain time reported for C is about --timeout-ms.
//
// Build: hipcc -O3 --offload-arch=gfx942 sdma_d2h_stall_repro.hip.cpp -o sdma_d2h_stall_repro
// Run:   ROC_P2P_SDMA_SIZE=0 GPU_FORCE_BLIT_COPY_SIZE=0 ./sdma_d2h_stall_repro --ranks 2
//        ROC_P2P_SDMA_SIZE=0 GPU_FORCE_BLIT_COPY_SIZE=0 ./sdma_d2h_stall_repro --ranks 2 --block-op none

#include <hip/hip_runtime.h>

#include <pthread.h>
#include <sys/mman.h>
#include <sys/wait.h>
#include <unistd.h>

#include <algorithm>
#include <atomic>
#include <chrono>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <cstring>
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

constexpr int kMaxRanks = 8;
constexpr uint32_t kSentinel = 0x7f817f81u;
// HIP 7.15 faults above 4096 copies per hipMemcpyBatchAsync call.
constexpr size_t kMaxBatchCopies = 4096;

struct Args {
    int ranks = 2;
    size_t chunk_bytes = 1 << 20;
    int chunks_per_peer = 32;
    size_t batch = 8;
    int batch_interval_us = 200;
    // d2h:      hipMemcpyAsync to pinned memory on the kernel's stream
    // d2h_sync: hipMemcpyWithStream to pageable memory, as PyTorch's .to() does
    // sync:     wait for the stream only
    // none:     same as sync, no delay
    std::string block_op = "d2h";
    int d2h_delay_us = 500;
    int timeout_ms = 10000;
    int iters = 3;
    bool null_stream = false;  // kernel and D2H on the legacy null stream, like PyTorch's default
};

struct RankResult {
    int iteration_failed[16];
    double kernel_ms[16];
    double copy_drain_ms[16];
    double last_issue_ms[16];
    double block_op_ms[16];
    int timed_out_sources[16];
};

struct Shared {
    pthread_barrier_t barrier;
    hipIpcMemHandle_t handles[kMaxRanks];
    RankResult results[kMaxRanks];
};

double now_ms() {
    return std::chrono::duration<double, std::milli>(
               std::chrono::steady_clock::now().time_since_epoch())
        .count();
}

size_t parse_size(const char* text) {
    char* end = nullptr;
    double value = std::strtod(text, &end);
    switch (*end) {
        case 'K': case 'k': value *= 1024; break;
        case 'M': case 'm': value *= 1024 * 1024; break;
        default: break;
    }
    return static_cast<size_t>(value);
}

Args parse(int argc, char** argv) {
    Args a;
    for (int i = 1; i < argc; ++i) {
        const std::string key = argv[i];
        auto next = [&]() {
            if (i + 1 >= argc) {
                std::fprintf(stderr, "missing value for %s\n", key.c_str());
                std::exit(2);
            }
            return argv[++i];
        };
        if (key == "--ranks") a.ranks = std::atoi(next());
        else if (key == "--chunk-bytes") a.chunk_bytes = parse_size(next());
        else if (key == "--chunks-per-peer") a.chunks_per_peer = std::atoi(next());
        else if (key == "--batch") a.batch = parse_size(next());
        else if (key == "--batch-interval-us") a.batch_interval_us = std::atoi(next());
        else if (key == "--block-op") a.block_op = next();
        else if (key == "--d2h-delay-us") a.d2h_delay_us = std::atoi(next());
        else if (key == "--timeout-ms") a.timeout_ms = std::atoi(next());
        else if (key == "--iters") a.iters = std::atoi(next());
        else if (key == "--null-stream") a.null_stream = true;
        else {
            std::fprintf(stderr,
                         "usage: %s [--ranks N] [--chunk-bytes B] [--chunks-per-peer N] "
                         "[--batch N] [--batch-interval-us US] "
                         "[--block-op d2h|d2h_sync|sync|none] "
                         "[--d2h-delay-us US] [--timeout-ms MS] [--iters N] [--null-stream]\n",
                         argv[0]);
            std::exit(2);
        }
    }
    if (a.ranks < 2 || a.ranks > kMaxRanks || a.chunk_bytes < 8 || a.chunk_bytes % 4 ||
        a.chunks_per_peer < 1 || a.batch < 1 || a.iters < 1 || a.iters > 16 ||
        (a.block_op != "d2h" && a.block_op != "d2h_sync" && a.block_op != "sync" &&
         a.block_op != "none")) {
        std::fprintf(stderr, "invalid arguments\n");
        std::exit(2);
    }
    a.batch = std::min(a.batch, kMaxBatchCopies);
    return a;
}

// One block per source rank. A chunk counts as landed once its first and last
// words differ from the sentinel; that is enough to tell completed copies
// from ones that never ran.
__global__ void wait_for_peers(const uint32_t* recv, int rank, size_t chunk_words,
                               int chunks_per_peer, uint64_t timeout_ticks,
                               int* timed_out_sources) {
    const int source = blockIdx.x;
    if (source == rank || threadIdx.x != 0) return;
    const uint32_t* region =
        recv + static_cast<size_t>(source) * chunks_per_peer * chunk_words;
    const uint64_t start = wall_clock64();
    for (int c = 0; c < chunks_per_peer; ++c) {
        const volatile uint32_t* chunk = region + static_cast<size_t>(c) * chunk_words;
        while (chunk[0] == kSentinel || chunk[chunk_words - 1] == kSentinel) {
            if (wall_clock64() - start > timeout_ticks) {
                atomicAdd(timed_out_sources, 1);
                return;
            }
        }
    }
}

void run_rank(int rank, const Args& a, Shared* shared) {
    CHECK(hipSetDevice(rank));
    const size_t chunk_words = a.chunk_bytes / 4;
    const size_t region_bytes = static_cast<size_t>(a.chunks_per_peer) * a.chunk_bytes;

    void* send = nullptr;
    void* recv = nullptr;
    CHECK(hipMalloc(&send, region_bytes * a.ranks));
    CHECK(hipExtMallocWithFlags(&recv, region_bytes * a.ranks, hipDeviceMallocUncached));
    CHECK(hipMemset(send, 0x11 + rank, region_bytes * a.ranks));
    CHECK(hipIpcGetMemHandle(&shared->handles[rank], recv));

    hipStream_t compute = nullptr, copy;
    if (!a.null_stream) CHECK(hipStreamCreateWithFlags(&compute, hipStreamNonBlocking));
    CHECK(hipStreamCreateWithFlags(&copy, hipStreamNonBlocking));
    int* timed_out_host = nullptr;
    CHECK(hipHostMalloc(&timed_out_host, sizeof(int), hipHostMallocMapped | hipHostMallocCoherent));
    int* timed_out_device = nullptr;
    CHECK(hipHostGetDevicePointer(reinterpret_cast<void**>(&timed_out_device), timed_out_host, 0));
    void* d2h_host = nullptr;
    CHECK(hipHostMalloc(&d2h_host, 64, hipHostMallocDefault));
    std::vector<uint8_t> d2h_pageable(64);
    void* d2h_device = nullptr;
    CHECK(hipMalloc(&d2h_device, 64));
    CHECK(hipDeviceSynchronize());
    pthread_barrier_wait(&shared->barrier);

    std::vector<uint8_t*> peer_recv(a.ranks, nullptr);
    for (int peer = 0; peer < a.ranks; ++peer) {
        if (peer == rank) continue;
        void* ptr = nullptr;
        CHECK(hipIpcOpenMemHandle(&ptr, shared->handles[peer], hipIpcMemLazyEnablePeerAccess));
        peer_recv[peer] = static_cast<uint8_t*>(ptr);
    }

    // Peer-interleaved descriptors, as the KIWI proxy batches them.
    std::vector<void*> dsts, srcs;
    std::vector<size_t> sizes;
    for (int c = 0; c < a.chunks_per_peer; ++c) {
        for (int step = 1; step < a.ranks; ++step) {
            const int peer = (rank + step) % a.ranks;
            dsts.push_back(peer_recv[peer] + rank * region_bytes + c * a.chunk_bytes);
            srcs.push_back(static_cast<uint8_t*>(send) + peer * region_bytes + c * a.chunk_bytes);
            sizes.push_back(a.chunk_bytes);
        }
    }

    // wall_clock64() ticks at 100 MHz on CDNA3.
    const uint64_t timeout_ticks = static_cast<uint64_t>(a.timeout_ms) * 100 * 1000;
    RankResult& result = shared->results[rank];
    for (int it = 0; it < a.iters; ++it) {
        CHECK(hipMemsetD32Async(static_cast<hipDeviceptr_t>(recv), kSentinel,
                                region_bytes * a.ranks / 4, compute));
        CHECK(hipStreamSynchronize(compute));
        *timed_out_host = 0;
        pthread_barrier_wait(&shared->barrier);

        const double start = now_ms();
        wait_for_peers<<<a.ranks, 64, 0, compute>>>(static_cast<const uint32_t*>(recv), rank,
                                                     chunk_words, a.chunks_per_peer,
                                                     timeout_ticks, timed_out_device);
        CHECK(hipGetLastError());

        std::atomic<double> last_issue{0}, drained{0};
        std::thread proxy([&]() {
            CHECK(hipSetDevice(rank));
            for (size_t off = 0; off < dsts.size(); off += a.batch) {
                const size_t count = std::min(a.batch, dsts.size() - off);
                size_t fail = 0;
                CHECK(hipMemcpyBatchAsync(dsts.data() + off, srcs.data() + off,
                                          sizes.data() + off, count, nullptr, nullptr, 0,
                                          &fail, copy));
                last_issue = now_ms() - start;
                std::this_thread::sleep_for(std::chrono::microseconds(a.batch_interval_us));
            }
            while (hipStreamQuery(copy) == hipErrorNotReady) std::this_thread::yield();
            drained = now_ms() - start;
        });

        double block_op_ms = 0;
        if (a.block_op == "d2h") {
            std::this_thread::sleep_for(std::chrono::microseconds(a.d2h_delay_us));
            block_op_ms = now_ms() - start;
            CHECK(hipMemcpyAsync(d2h_host, d2h_device, 64, hipMemcpyDeviceToHost, compute));
        } else if (a.block_op == "d2h_sync") {
            std::this_thread::sleep_for(std::chrono::microseconds(a.d2h_delay_us));
            block_op_ms = now_ms() - start;
            CHECK(hipMemcpyWithStream(d2h_pageable.data(), d2h_device, 64,
                                      hipMemcpyDeviceToHost, compute));
        } else if (a.block_op == "sync") {
            std::this_thread::sleep_for(std::chrono::microseconds(a.d2h_delay_us));
            block_op_ms = now_ms() - start;
        }
        CHECK(hipStreamSynchronize(compute));
        const double kernel_ms = now_ms() - start;
        proxy.join();

        result.timed_out_sources[it] = *timed_out_host;
        result.iteration_failed[it] = *timed_out_host != 0;
        result.kernel_ms[it] = kernel_ms;
        result.copy_drain_ms[it] = drained;
        result.last_issue_ms[it] = last_issue;
        result.block_op_ms[it] = block_op_ms;
        pthread_barrier_wait(&shared->barrier);
    }

    for (int peer = 0; peer < a.ranks; ++peer)
        if (peer_recv[peer]) CHECK(hipIpcCloseMemHandle(peer_recv[peer]));
}

}  // namespace

int main(int argc, char** argv) {
    const Args a = parse(argc, argv);
    const char* sdma = std::getenv("ROC_P2P_SDMA_SIZE");
    const char* blit = std::getenv("GPU_FORCE_BLIT_COPY_SIZE");
    std::printf("ROC_P2P_SDMA_SIZE=%s GPU_FORCE_BLIT_COPY_SIZE=%s ranks=%d chunk=%zu "
                "chunks/peer=%d batch=%zu batch_interval=%dus block_op=%s d2h_delay=%dus "
                "timeout=%dms stream=%s\n",
                sdma ? sdma : "(unset)", blit ? blit : "(unset)", a.ranks, a.chunk_bytes,
                a.chunks_per_peer, a.batch, a.batch_interval_us, a.block_op.c_str(),
                a.d2h_delay_us, a.timeout_ms, a.null_stream ? "null" : "non-blocking");

    auto* shared = static_cast<Shared*>(mmap(nullptr, sizeof(Shared), PROT_READ | PROT_WRITE,
                                             MAP_SHARED | MAP_ANONYMOUS, -1, 0));
    if (shared == MAP_FAILED) {
        std::perror("mmap");
        return 1;
    }
    std::memset(shared, 0, sizeof(Shared));
    pthread_barrierattr_t attr;
    pthread_barrierattr_init(&attr);
    pthread_barrierattr_setpshared(&attr, PTHREAD_PROCESS_SHARED);
    pthread_barrier_init(&shared->barrier, &attr, a.ranks);

    std::vector<pid_t> children;
    for (int rank = 0; rank < a.ranks; ++rank) {
        const pid_t pid = fork();
        if (pid == 0) {
            run_rank(rank, a, shared);
            std::_Exit(0);
        }
        children.push_back(pid);
    }
    int failures = 0;
    for (pid_t pid : children) {
        int status = 0;
        waitpid(pid, &status, 0);
        if (!WIFEXITED(status) || WEXITSTATUS(status) != 0) ++failures;
    }
    if (failures) {
        std::fprintf(stderr, "%d rank(s) failed\n", failures);
        return 1;
    }

    int stalled_iterations = 0;
    for (int it = 0; it < a.iters; ++it) {
        bool stalled = false;
        for (int r = 0; r < a.ranks; ++r) {
            const RankResult& res = shared->results[r];
            std::printf("iter %d rank %d: %s kernel=%.3f ms last_copy_issued=%.3f ms "
                        "copy_stream_drained=%.3f ms block_op_at=%.3f ms "
                        "timed_out_sources=%d\n",
                        it, r, res.iteration_failed[it] ? "STALLED" : "ok", res.kernel_ms[it],
                        res.last_issue_ms[it], res.copy_drain_ms[it], res.block_op_ms[it],
                        res.timed_out_sources[it]);
            stalled |= res.iteration_failed[it] != 0;
        }
        stalled_iterations += stalled;
    }
    std::printf("result block_op=%s stalled_iterations=%d/%d\n", a.block_op.c_str(),
                stalled_iterations, a.iters);
    return stalled_iterations ? 3 : 0;
}
