// Host-side test drive for the KIWI SDMA proxy's copy API.
//
// Replays the EP dispatch copy pattern directly into hipMemcpyBatchAsync, with
// no KIWI queue, GPU sender, receiver, or ACK in the loop. Each rank is a
// separate process (as in training), owns one GPU and one non-blocking copy
// stream, and sends --bytes-per-peer to every other rank in --chunk-bytes
// copies. Descriptors are interleaved across destination ranks (or grouped by
// destination with --order grouped), and each API call carries --batch of
// them, matching one proxy progress sweep. --streams spreads successive calls
// over several copy streams; --uncached-dst allocates the receive buffer like
// DeepEP's NVL buffer.
//
// Per rank it reports time spent inside the API calls (host stall), time to
// issue everything, time to completion, and the slowest single call. If the
// API time alone approaches the end-to-end dispatch time, the proxy is bound
// by host-side submission rather than by the copies themselves.
//
// Build:  hipcc -O3 --offload-arch=gfx942 sdma_host_api_drive.hip.cpp -o sdma_host_api_drive
// Run:    ROC_P2P_SDMA_SIZE=0 GPU_FORCE_BLIT_COPY_SIZE=0 ./sdma_host_api_drive --ranks 8

#include <hip/hip_runtime.h>

#include <pthread.h>
#include <sys/mman.h>
#include <sys/wait.h>
#include <unistd.h>

#include <algorithm>
#include <chrono>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <string>
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
// hipMemcpyBatchAsync in HIP 7.15 faults above 4096 copies per call.
constexpr size_t kMaxBatchCopies = 4096;

struct Args {
    int ranks = 8;
    size_t chunk_bytes = 64 * 1024;
    size_t bytes_per_peer = 40ull << 20;
    size_t batch = 64;
    int iters = 5;
    int warmup = 1;
    std::string api = "batch";  // batch | single
    std::string order = "interleaved";  // interleaved | grouped
    int streams = 1;  // batch call k goes to stream k % streams
    bool uncached_dst = false;  // receive buffer like DeepEP's NVL buffer
};

struct RankStats {
    double api_ms;
    double max_call_us;
    double issue_ms;
    double total_ms;
    long calls;
    long copies;
};

struct Shared {
    pthread_barrier_t barrier;
    hipIpcMemHandle_t handles[kMaxRanks];
    RankStats stats[kMaxRanks];
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
        case 'G': case 'g': value *= 1024.0 * 1024 * 1024; break;
        default: break;
    }
    return static_cast<size_t>(value);
}

Args parse(int argc, char** argv) {
    Args a;
    for (int i = 1; i < argc; ++i) {
        std::string key = argv[i];
        auto next = [&]() {
            if (i + 1 >= argc) {
                std::fprintf(stderr, "missing value for %s\n", key.c_str());
                std::exit(2);
            }
            return argv[++i];
        };
        if (key == "--ranks") a.ranks = std::atoi(next());
        else if (key == "--chunk-bytes") a.chunk_bytes = parse_size(next());
        else if (key == "--bytes-per-peer") a.bytes_per_peer = parse_size(next());
        else if (key == "--batch") a.batch = parse_size(next());
        else if (key == "--iters") a.iters = std::atoi(next());
        else if (key == "--warmup") a.warmup = std::atoi(next());
        else if (key == "--api") a.api = next();
        else if (key == "--order") a.order = next();
        else if (key == "--streams") a.streams = std::atoi(next());
        else if (key == "--uncached-dst") a.uncached_dst = true;
        else {
            std::fprintf(stderr,
                         "usage: %s [--ranks N] [--chunk-bytes B] [--bytes-per-peer B] "
                         "[--batch N] [--iters N] [--warmup N] [--api batch|single] "
                         "[--order interleaved|grouped] [--streams N] [--uncached-dst]\n",
                         argv[0]);
            std::exit(2);
        }
    }
    if (a.ranks < 2 || a.ranks > kMaxRanks || a.chunk_bytes == 0 || a.batch == 0 ||
        a.bytes_per_peer < a.chunk_bytes || (a.api != "batch" && a.api != "single") ||
        (a.order != "interleaved" && a.order != "grouped") || a.streams < 1) {
        std::fprintf(stderr, "invalid arguments\n");
        std::exit(2);
    }
    a.batch = std::min(a.batch, kMaxBatchCopies);
    return a;
}

void run_rank(int rank, const Args& a, Shared* shared) {
    CHECK(hipSetDevice(rank));
    const size_t copies_per_peer = a.bytes_per_peer / a.chunk_bytes;
    const size_t region = copies_per_peer * a.chunk_bytes;

    void* send = nullptr;
    void* recv = nullptr;
    CHECK(hipMalloc(&send, region * a.ranks));
    if (a.uncached_dst)
        CHECK(hipExtMallocWithFlags(&recv, region * a.ranks, hipDeviceMallocUncached));
    else
        CHECK(hipMalloc(&recv, region * a.ranks));
    CHECK(hipMemset(send, rank + 1, region * a.ranks));
    CHECK(hipIpcGetMemHandle(&shared->handles[rank], recv));
    std::vector<hipStream_t> streams(a.streams);
    for (auto& s : streams) CHECK(hipStreamCreateWithFlags(&s, hipStreamNonBlocking));
    CHECK(hipDeviceSynchronize());
    pthread_barrier_wait(&shared->barrier);

    std::vector<uint8_t*> peer_recv(a.ranks, nullptr);
    for (int peer = 0; peer < a.ranks; ++peer) {
        if (peer == rank) continue;
        void* ptr = nullptr;
        CHECK(hipIpcOpenMemHandle(&ptr, shared->handles[peer],
                                  hipIpcMemLazyEnablePeerAccess));
        peer_recv[peer] = static_cast<uint8_t*>(ptr);
    }

    // Peer-interleaved order spreads every batch across all XGMI links;
    // "grouped" issues each peer's copies back to back, as the KIWI proxy's
    // endpoint sweep does.
    std::vector<void*> dsts, srcs;
    std::vector<size_t> sizes;
    const bool grouped = a.order == "grouped";
    const size_t outer = grouped ? a.ranks - 1 : copies_per_peer;
    const size_t inner = grouped ? copies_per_peer : a.ranks - 1;
    for (size_t o = 0; o < outer; ++o) {
        for (size_t n = 0; n < inner; ++n) {
            const size_t i = grouped ? n : o;
            const int peer = (rank + 1 + static_cast<int>(grouped ? o : n)) % a.ranks;
            dsts.push_back(peer_recv[peer] + rank * region + i * a.chunk_bytes);
            srcs.push_back(static_cast<uint8_t*>(send) + peer * region + i * a.chunk_bytes);
            sizes.push_back(a.chunk_bytes);
        }
    }

    RankStats best{};
    best.total_ms = 1e30;
    for (int it = 0; it < a.warmup + a.iters; ++it) {
        CHECK(hipDeviceSynchronize());
        pthread_barrier_wait(&shared->barrier);
        RankStats s{};
        const double start = now_ms();
        for (size_t off = 0; off < dsts.size(); off += a.batch) {
            const size_t count = std::min(a.batch, dsts.size() - off);
            hipStream_t stream = streams[(off / a.batch) % streams.size()];
            const double call_start = now_ms();
            if (a.api == "batch") {
                size_t fail = 0;
                CHECK(hipMemcpyBatchAsync(dsts.data() + off, srcs.data() + off,
                                          sizes.data() + off, count, nullptr, nullptr, 0,
                                          &fail, stream));
            } else {
                for (size_t i = off; i < off + count; ++i)
                    CHECK(hipMemcpyAsync(dsts[i], srcs[i], sizes[i],
                                         hipMemcpyDeviceToDevice, stream));
            }
            const double call_ms = now_ms() - call_start;
            s.api_ms += call_ms;
            s.max_call_us = std::max(s.max_call_us, call_ms * 1e3);
            ++s.calls;
            s.copies += static_cast<long>(count);
        }
        s.issue_ms = now_ms() - start;
        for (auto stream : streams) CHECK(hipStreamSynchronize(stream));
        s.total_ms = now_ms() - start;
        if (it >= a.warmup && s.total_ms < best.total_ms) best = s;
    }
    shared->stats[rank] = best;
    pthread_barrier_wait(&shared->barrier);

    for (int peer = 0; peer < a.ranks; ++peer)
        if (peer_recv[peer]) CHECK(hipIpcCloseMemHandle(peer_recv[peer]));
    for (auto stream : streams) CHECK(hipStreamDestroy(stream));
    CHECK(hipFree(send));
    CHECK(hipFree(recv));
}

}  // namespace

int main(int argc, char** argv) {
    const Args a = parse(argc, argv);
    const char* sdma = std::getenv("ROC_P2P_SDMA_SIZE");
    const char* blit = std::getenv("GPU_FORCE_BLIT_COPY_SIZE");
    if (!sdma || std::string(sdma) != "0" || !blit || std::string(blit) != "0")
        std::fprintf(stderr,
                     "warning: ROC_P2P_SDMA_SIZE=0 GPU_FORCE_BLIT_COPY_SIZE=0 are not set; "
                     "small peer copies may run as CU blit kernels\n");

    // Shared state lives in an anonymous mapping created before fork; HIP is
    // only initialized inside each child.
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

    const size_t copies_per_peer = a.bytes_per_peer / a.chunk_bytes;
    const double rank_bytes =
        static_cast<double>(copies_per_peer * a.chunk_bytes) * (a.ranks - 1);
    double max_api = 0, max_issue = 0, max_total = 0, max_call = 0;
    long copies = 0, calls = 0;
    for (int r = 0; r < a.ranks; ++r) {
        const RankStats& s = shared->stats[r];
        std::printf("rank %d api=%.3f ms issue=%.3f ms total=%.3f ms max_call=%.1f us "
                    "calls=%ld copies=%ld per_copy_api=%.2f us\n",
                    r, s.api_ms, s.issue_ms, s.total_ms, s.max_call_us, s.calls, s.copies,
                    s.copies ? s.api_ms * 1e3 / s.copies : 0.0);
        max_api = std::max(max_api, s.api_ms);
        max_issue = std::max(max_issue, s.issue_ms);
        max_total = std::max(max_total, s.total_ms);
        max_call = std::max(max_call, s.max_call_us);
        copies = s.copies;
        calls = s.calls;
    }
    std::printf("result api=%s ranks=%d chunk=%zu batch=%zu copies/rank=%ld calls/rank=%ld "
                "bytes/rank=%.1f MiB | max api=%.3f ms issue=%.3f ms total=%.3f ms "
                "max_call=%.1f us | api_share=%.1f%% per_rank_bw=%.2f GB/s\n",
                a.api.c_str(), a.ranks, a.chunk_bytes, a.batch, copies, calls,
                rank_bytes / (1 << 20), max_api, max_issue, max_total, max_call,
                max_total > 0 ? 100.0 * max_api / max_total : 0.0,
                rank_bytes / (max_total * 1e6));
    return 0;
}
