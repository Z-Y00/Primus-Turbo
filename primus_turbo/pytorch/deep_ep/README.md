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
GPU sender workgroups compact routed BF16/FP16 or FP8+scale rows across all
channels for each destination into approximately 256 KiB chunks in an
eight-slot ring, then invoke a vendored KIWI device-to-host queue. A CPU proxy
combines mixed-destination descriptors observed in one progress pass into
`hipMemcpyBatchAsync`.
Receivers poll an exact signaling-NaN bit pattern and load ready hidden rows
directly into LDS before publishing the normal DeepEP receive tensors.

The backend changes dispatch only. Combine continues to use the existing
TURBO CU implementation and consumes the same dispatch handle.

ROCm 7.15 selects a CU blit kernel for small peer copies by default. Set these
variables **before launching Python**:

```bash
export ROC_P2P_SDMA_SIZE=0
export GPU_FORCE_BLIT_COPY_SIZE=0
export PRIMUS_TURBO_MOE_DISPATCH_COMBINE_BACKEND=KIWI_SDMA
# Optional: pin each process's proxy thread to this logical CPU.
export KIWI_SDMA_PROXY_CPU=4
```

Use `benchmark/ops/training/bench_kiwi_sdma_dispatch.py` for focused
2-, 4-, or 8-rank BF16/FP16/FP8 measurements. It reports cached-dispatch latency,
cross-rank payload bandwidth, chunk geometry, and proxy affinity. When
`KIWI_SDMA_PROXY_CPU` is set, the benchmark treats it as a base and pins rank
`r` to `base + r`.

Current limitations:

- single-node groups only;
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
counter. `ROC_P2P_SDMA_SIZE=0` and `GPU_FORCE_BLIT_COPY_SIZE=0` are mandatory
for this opt-in mode as well. MegaMoE MXFP8 uses the E4M3 FNUZ NaN encoding
`0x80` as its data sentinel (`0x7f` is a valid finite maximum in this format)
and `0xff` as its E8M0 scale sentinel.
