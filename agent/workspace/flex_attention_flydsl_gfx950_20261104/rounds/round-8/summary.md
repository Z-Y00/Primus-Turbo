# Round 8 — ACCEPTED: V^T via ds_read_b64_tr_b16 from a (row & 3) << 1 swizzled V tile, on batched staging

## Hypothesis

Round 6's transpose reads (63% fewer LDS instructions) lost on causal because the loop was serialized; round 7 removed the staging serialization. Re-applied on top, the read savings should now show on every shape.

## Single change

flash_fwd.py (gfx950 16-bit): P . V A fragments from two LDSReadTrans16_64b reads; V staging stores and the reads XOR the 16-byte chunk with (row & 3) * 2 (round 6's corrected swizzle). gfx942 / fp8 unchanged (element reads, unswizzled V).

## Results

- Validation: full (13 shapes) on a17-31's 8 GPUs; each shape's reference and candidate ran on the same GPU
  (`artifacts/validation.log`, gpu map at the end); tests before benchmarks.
- Raw artifacts: `artifacts/benchmark.csv`, `artifacts/round7_reference_same_gpu.csv`

| shape | Check | ref fwd ms | fwd ms | fwd change | ref bwd ms | bwd ms | bwd change | fwd vs Triton | bwd vs Triton |
|---|---|---|---|---|---|---|---|---|---|
| causal_s4k | PASS | 1.148 | 1.027 | +11.9% | 6.981 | 6.991 | -0.1% | 1.66x | 2.31x |
| causal_s8k | PASS | 1.785 | 1.552 | +15.0% | 12.068 | 12.088 | -0.2% | 1.50x | 2.11x |
| window1k_s8k | PASS | 0.543 | 0.495 | +9.6% | 2.283 | 2.264 | +0.8% | 1.52x | 1.65x |
| band1k_s8k | PASS | 0.840 | 0.753 | +11.6% | 3.768 | 3.779 | -0.3% | 1.40x | 1.04x |
| prefix_lm_s8k | PASS | 2.031 | 1.752 | +15.9% | 11.959 | 11.936 | +0.2% | 1.62x | 1.66x |
| inkling_global_1doc | PASS | 2.055 | 1.744 | +17.8% | 10.642 | 10.663 | -0.2% | 0.94x | 1.92x |
| inkling_global_5doc | PASS | 0.710 | 0.648 | +9.6% | 4.560 | 4.548 | +0.3% | 0.95x | 1.90x |
| inkling_local_1doc | PASS | 0.440 | 0.432 | +1.9% | 1.834 | 1.886 | -2.7% | 0.97x | 1.54x |
| inkling_local_5doc | PASS | 0.490 | 0.477 | +2.7% | 2.442 | 2.486 | -1.8% | 1.07x | 1.79x |
| inkling_small_global_1doc | PASS | 1.157 | 0.982 | +17.8% | 5.942 | 5.915 | +0.5% | 0.79x | 2.07x |
| inkling_small_global_5doc | PASS | 0.568 | 0.503 | +13.1% | 2.537 | 2.506 | +1.2% | 1.00x | 1.51x |
| inkling_small_local_1doc | PASS | 0.310 | 0.301 | +2.9% | 1.147 | 1.135 | +1.1% | 1.08x | 1.35x |
| inkling_small_local_5doc | PASS | 0.349 | 0.344 | +1.3% | 1.461 | 1.429 | +2.2% | 1.19x | 1.50x |

- Forward geomean: 122.902 -> 135.096 TFLOPS (+9.9%)
- Backward geomean: 61.860 -> 61.899 TFLOPS (+0.1%)

## Decision

`ACCEPTED`

## Attribution

Forward +1% to +18% on every shape; causal 8K 1.785 -> 1.552 ms (+15%). With staging loads overlapped, the P . V fragment reads were the next serial cost, and the transpose reads cut them from 8 to 2 per fragment.

## Real-training transfer check
- Bucket: K1 (kernel-internal / launch configuration); no cache
- Estimated real-training gain: same as benchmark
- Decision: ACCEPT-as-real

## Next direction

Forward VALU (exp2 range fix-ups, scale / max subtraction as separate ops, compare + select max), then the backward register footprint (dQ 336, dK/dV 464).
