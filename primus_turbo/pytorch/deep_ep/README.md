## DeepEP (experimental)

DeepEP of Primus-Turbo is in the experimental stage.
The kernel code of DeepEP is primarily derived from ROCm internal DeepEP (it's still under development). It's **only used for training** and doesn't support low-latency kernels.

### Installation

#### 1. Dependencies

Hardware
- only Supported MI300 (gfx942)

#### 2. Docker (Recommended)

Use AMD ROCm image:
```
docker.io/rocm/megatron-lm:v25.5_py310
```

#### 3. Install rocSHMEM (optional)

rocSHMEM is required for internode api of experimental DeepEP. Please refer to [our rocSHMEM Installation Guide](../../../docs/install_dependencies.md) for instructions.

> **Please Note: rocSHMEM is under development, no guarantee of full compatibility and performance for bnxt,mlx5 and ionic NIC driver.**

#### 4. Install from source
Please following [Primus-Turbo Install from Source](../../../README.md#3-install-from-source) instructions to install.

### Example

See [DeepEP example](../../../docs/examples.md#4-deepep)

### Benchmark Usage

 See [DeepEP benchmark](../../../benchmark/README.md#deepep)

### KIWI SDMA dispatch backend

`KIWI_SDMA` is an experimental intranode dispatch transport for 2–8 ranks.
Every receiver reserves one record per row it can receive, after the bytes the
CU kernels use in the NVL buffer, in final `recv_x` order. A dispatch therefore
never reuses receive memory: there is no ring, ACK, or in-iteration re-arm. The
records are armed with sentinels once per dispatch, before the barrier, and
each receiver tells every source where its rows start.

One sender workgroup per (destination, channel) packs that channel's rows into
local staging and copies runs of up to 1 MiB with a single descriptor through a
vendored KIWI device-to-host queue. A CPU proxy combines the mixed-destination
descriptors observed in one progress pass into `hipMemcpyBatchAsync`, so one
call spreads copies across all XGMI links. Rows that stay on the local GPU are
written directly by the CU. One receiver workgroup per (source, channel) polls
an exact signaling-NaN pattern over each row's metadata, hidden, and scale
words, loads the ready row into LDS, and writes the normal DeepEP receive
tensors.

Size the NVL buffer with `Buffer.get_kiwi_sdma_nvl_buffer_size_hint()`; the
`KIWI_SDMA` MoE backend does this automatically for
`PRIMUS_TURBO_KIWI_SDMA_MAX_TOKENS` tokens per rank (default 4096) and
`PRIMUS_TURBO_KIWI_SDMA_MAX_TOPK` experts (default 32). A dispatch that would
receive more rows fails with an explicit error.

The backend changes dispatch only. Combine continues to use the existing
TURBO CU implementation and consumes the same dispatch handle.

ROCm chooses between SDMA and a CU blit kernel per copy by size.
`GPU_FORCE_BLIT_COPY_SIZE` (KB, default 16) runs copies up to that size as
blit kernels, and `ROC_P2P_SDMA_SIZE` (KB, default 1024) is the size above
which peer copies use SDMA; by default every KIWI chunk of up to 1 MiB would
therefore run on CUs. Set both to 64 **before launching Python**, so KIWI
chunks use SDMA while small copies, such as PyTorch's device-to-host reads of
token counts, stay on blit kernels:

```bash
export ROC_P2P_SDMA_SIZE=64
export GPU_FORCE_BLIT_COPY_SIZE=64
export PRIMUS_TURBO_MOE_DISPATCH_COMBINE_BACKEND=KIWI_SDMA
# Optional: pin each process's proxy thread to this logical CPU.
export KIWI_SDMA_PROXY_CPU=4
```

Use `benchmark/ops/training/bench_kiwi_sdma_dispatch.py` for focused
2-, 4-, or 8-rank BF16/FP16/FP8 measurements. It reports cached-dispatch latency,
cross-rank payload bandwidth, chunk geometry, and proxy affinity. When
`KIWI_SDMA_PROXY_CPU` is set, the benchmark treats it as a base and pins rank
`r` to `base + r`. `benchmark/ops/training/bench_moe_ep_backend.py` times the
whole MoE layer (dispatch, grouped FC1, SwiGLU, grouped FC2, combine) for any
EP backend; `--breakdown` adds per-stage times.
`benchmark/sdma_kiwi_proto/sdma_host_api_drive.hip.cpp` replays the dispatch
copy pattern straight into `hipMemcpyBatchAsync` across one process per GPU.

Set `KIWI_SDMA_PROFILE=1` to print per-second proxy statistics: copies,
batch sizes, time inside `hipMemcpyBatchAsync`, and whether the copy stream
still has unfinished work. A dispatch wait that exceeds 30 s ends the kernel
and prints which wait failed (`[KIWI_SDMA_DEVICE]` / `[KIWI_SDMA_FAILURE]`).

Status on MI300X (`rocm/primus:v26.7`, ROCm 7.15):

- the 2-rank suite passes (BF16, FP16, FP8 with scales, cached replay, zero
  peers, duplicate experts, `-1` routes, CU combine);
- 8-rank dispatch alone, 4096 tokens sent to every rank at hidden 7168, runs
  repeatedly warm at about 4.2 ms per dispatch (about 98 GB/s cross-rank
  payload per rank);
- the full MoE layer at EP4 (hidden 7168, intermediate 2048, 256 experts,
  top-8, 4096 tokens per rank) runs warm with the output checksum matching
  `TURBO`: 16.0 ms per forward iteration versus 11.9 ms for `TURBO`;
- **do not set both variables to 0.** That routes every copy, including the
  small device-to-host reads PyTorch makes while the dispatch kernel is still
  running, to SDMA. Inside the full MoE layer every dispatch after the first
  then stalls: the proxy submits all copies but the copy stream stops
  completing them and the receivers time out. A standalone reproducer
  (`benchmark/sdma_kiwi_proto/sdma_d2h_stall_repro.hip.cpp`) does not yet
  trigger this outside PyTorch;
- a dispatch measured alone (with device synchronization before and after)
  takes far longer than its share of a warm iteration (about 143 ms at EP4);
  this is not yet understood;
- EP8 inside the full MoE layer has not been rerun with the 64 KB settings.

Current limitations:

- single-node groups only;
- memory: the receive region holds `num_ranks × max_tokens_per_rank` records
  and the send staging has the same size, about 475 MB each per rank at EP8,
  4096 tokens, hidden 7168;
- BF16/FP16 inputs must not contain the reserved signaling-NaN bit pattern
  `0x7f81`; FP8 E4M3 inputs must not contain `0x7f` or `0xff`, and FP8
  scales must be finite;
- the backend is not CUDA-graph capturable because progress and copy
  submission run on a host proxy thread.

MegaMoE keeps its fused CU-copy dispatch by default. To opt its BF16 and
MXFP8 paths into the same KIWI proxy and batched-SDMA transport, additionally
set:

```bash
export PRIMUS_TURBO_MEGA_MOE_DISPATCH=KIWI_SDMA
```

MegaMoE preserves its prologue/handle ABI and CU combine. Its sender packs
each expert/source-rank segment into contiguous row chunks (64 KiB payloads
where counts permit). Before each dispatch, ranks re-arm and rendezvous on
the destination pool; the GEMM side uses system-coherent bitwise sentinel
polling over every valid BF16 or FP8+scale word instead of the CU completion
counter. This mode also needs `ROC_P2P_SDMA_SIZE` and
`GPU_FORCE_BLIT_COPY_SIZE` set, at most 64 (KB) because its copies are about
64 KiB; it has not been run on gfx950 hardware yet. MegaMoE MXFP8 uses the E4M3 FNUZ NaN encoding
`0x80` as its data sentinel (`0x7f` is a valid finite maximum in this format)
and `0xff` as its E8M0 scale sentinel.
