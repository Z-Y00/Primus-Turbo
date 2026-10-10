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
never reuses receive memory: there is no ring, ACK, or re-arm. Before each
dispatch, each receiver tells every source where its rows start.

A send kernel runs one workgroup per (destination, channel). It finds the row
position of every token in its channel with a block-wide scan, packs one row
per wavefront into local staging, and posts SDMA copy descriptors through a
vendored KIWI device-to-host queue, then exits. By default the channel that
finishes last posts one descriptor for the destination's whole contiguous block
(7 copies per rank per dispatch at EP8). With
`PRIMUS_TURBO_KIWI_SDMA_CHUNK_BYTES=<bytes>` each channel instead posts a copy
whenever about that many bytes are packed, overlapping packing with the
transfer. Rows that stay on the local GPU are written directly into the
outputs.

A CPU proxy combines the mixed-destination descriptors observed in one
progress pass into `hipMemcpyBatchAsync`, so one call spreads copies across all
XGMI links. After a destination's copies it writes the dispatch epoch into the
destination's flag slot with `hipStreamWriteValue64` on the same copy stream,
so a flag implies the data has landed. On the receiver, a one-workgroup kernel
waits for every peer's flag and a plain kernel unpacks the records into the
normal DeepEP receive tensors. Nothing polls the payload, and no workgroups are
held while the copies are in flight.

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
- the full MoE layer (hidden 7168, intermediate 2048, 256 experts, top-8,
  4096 tokens per rank) runs warm with the output checksum matching `TURBO`.
  At EP8 with 64 KB thresholds, per-stage GPU time from stream events (`--breakdown`,
  max over ranks; dispatch and combine run serially with compute, so all of it is
  exposed):

  | Dispatch | Copies per rank | Dispatch | Combine (CU) | Compute | MoE forward |
  |---|---|---|---|---|---|
  | `KIWI_SDMA`, one copy per destination (default) | 7 | 2.69 ms | 2.34 ms | 7.70 ms | 12.46 ms |
  | `KIWI_SDMA`, `PRIMUS_TURBO_KIWI_SDMA_CHUNK_BYTES=1048576` | ~420 | 2.24 ms | 2.34 ms | 7.72 ms | 11.97 ms |
  | `TURBO` | | 1.94 ms | 2.27 ms | 7.62 ms | 11.63 ms |

  One copy per destination needs about 3 `hipMemcpyBatchAsync` calls per
  dispatch instead of about 52, but packing no longer overlaps the transfer;
- **do not set both variables to 0.** That routes every copy, including the
  small device-to-host reads PyTorch makes while the dispatch kernel is still
  running, to SDMA. Inside the full MoE layer every dispatch after the first
  then stalls: the proxy submits all copies but the copy stream stops
  completing them and the receivers time out. A standalone reproducer
  (`benchmark/sdma_kiwi_proto/sdma_d2h_stall_repro.hip.cpp`) does not yet
  trigger this outside PyTorch.

Current limitations:

- single-node groups only;
- memory: the receive region holds `num_ranks × max_tokens_per_rank` records
  and the send staging has the same size, about 475 MB each per rank at EP8,
  4096 tokens, hidden 7168;
- dispatch is still synchronous: its flag wait and unpack run on the caller's
  stream right after the send kernel, so the SDMA transfer is not yet
  overlapped with other work;
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
