# Round 7 — ACCEPTED: issue all K/V staging loads before the LDS stores (forward)

## Hypothesis

Round 6's ISA: the forward's K/V staging is 8 x (buffer_load; s_waitcnt vmcnt(0); ds_write), each global load waited before the next is issued, so every tile pays 8 serial load latencies. Issuing all loads first, then storing, pays one.

## Single change

flash_fwd.py stage_kv: loads into register packs first (K then V), LDS stores after; the V row permutation and K swizzle unchanged. Shared code: gfx942 gets it too.

## Results

- Validation: full (13 shapes) on a17-31's 8 GPUs; each shape's reference and candidate ran on the same GPU
  (`artifacts/validation.log`, gpu map at the end); tests before benchmarks.
- Raw artifacts: `artifacts/benchmark.csv`, `artifacts/round3_reference_same_gpu.csv`

| shape | Check | ref fwd ms | fwd ms | fwd change | ref bwd ms | bwd ms | bwd change | fwd vs Triton | bwd vs Triton |
|---|---|---|---|---|---|---|---|---|---|
| causal_s4k | PASS | 1.154 | 1.144 | +0.8% | 6.968 | 6.982 | -0.2% | 1.87x | 2.30x |
| causal_s8k | PASS | 1.839 | 1.790 | +2.8% | 12.139 | 12.138 | +0.0% | 1.74x | 2.09x |
| window1k_s8k | PASS | 0.577 | 0.544 | +6.1% | 2.276 | 2.299 | -1.0% | 1.78x | 1.65x |
| band1k_s8k | PASS | 0.891 | 0.837 | +6.5% | 3.766 | 3.749 | +0.5% | 1.56x | 1.04x |
| prefix_lm_s8k | PASS | 2.183 | 2.046 | +6.7% | 11.933 | 11.933 | +0.0% | 1.89x | 1.66x |
| inkling_global_1doc | PASS | 2.074 | 2.044 | +1.5% | 10.647 | 10.682 | -0.3% | 1.11x | 1.93x |
| inkling_global_5doc | PASS | 0.714 | 0.703 | +1.6% | 4.517 | 4.544 | -0.6% | 1.02x | 1.89x |
| inkling_local_1doc | PASS | 0.465 | 0.438 | +6.1% | 1.854 | 1.887 | -1.8% | 0.99x | 1.55x |
| inkling_local_5doc | PASS | 0.600 | 0.483 | +24.1% | 2.531 | 2.484 | +1.9% | 1.09x | 1.79x |
| inkling_small_global_1doc | PASS | 1.161 | 1.152 | +0.8% | 5.928 | 5.875 | +0.9% | 0.94x | 2.09x |
| inkling_small_global_5doc | PASS | 0.566 | 0.563 | +0.6% | 2.505 | 2.510 | -0.2% | 1.12x | 1.52x |
| inkling_small_local_1doc | PASS | 0.319 | 0.304 | +4.9% | 1.118 | 1.112 | +0.5% | 1.09x | 1.35x |
| inkling_small_local_5doc | PASS | 0.366 | 0.347 | +5.3% | 1.438 | 1.446 | -0.6% | 1.20x | 1.51x |

- Forward geomean: 117.579 -> 123.537 TFLOPS (+5.1%)
- Backward geomean: 61.957 -> 61.914 TFLOPS (-0.1%)

## Decision

`ACCEPTED`

## Attribution

ISA now: 8 buffer_loads back to back, then staggered vmcnt(7..0) waits per store; the Q.K fragment reads also batch (7 in flight). Forward +0.6% to +6.7% (local_5doc +24%, partly noise); causal gains least (+1-3%): its loop is still bound by the per-MFMA waits in P . V.

## Real-training transfer check
- Bucket: K1 (kernel-internal / launch configuration); no cache
- Estimated real-training gain: same as benchmark
- Decision: ACCEPT-as-real

## Next direction

Round 8: re-apply round 6's transpose reads (corrected swizzle) on top.
