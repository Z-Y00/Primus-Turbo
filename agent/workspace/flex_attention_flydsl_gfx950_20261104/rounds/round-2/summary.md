# Round 2 — ACCEPTED: 32x32x16 MFMA in the forward for 16-bit inputs on gfx950

## Hypothesis

gfx950 has a 32x32x16 bf16/fp16 MFMA, twice the reduction depth per instruction of gfx942's 32x32x8 that the forward uses. The forward's fp8 path already runs a 16-deep step (8-element fragments; V rows permuted so the accumulator layout feeds the P . V B operand). Expected: fewer MFMA issues and fragment loads per tile, faster forward on every shape.

## Single change

flash_fwd.py: `mfma_k` (16 for fp8 and, by default, for bf16 / fp16 on gfx950; 8 otherwise): KS = mfma_k, Q / K fragment copies 128-bit when 8 x 16-bit, V rows permuted whenever KS = 16. gfx942 keeps 32x32x8 (unchanged code path).

## Results

- Validation: full (13 shapes) on a17-31's 8 GPUs; each shape's reference and candidate ran on the same GPU
  (`artifacts/validation.log`, gpu map at the end); tests before benchmarks.
- Raw artifacts: `artifacts/benchmark.csv`, `artifacts/round1_reference_same_gpu.csv`

| shape | Check | ref fwd ms | fwd ms | fwd change | ref bwd ms | bwd ms | bwd change | fwd vs Triton | bwd vs Triton |
|---|---|---|---|---|---|---|---|---|---|
| causal_s4k | PASS | 1.565 | 1.147 | +36.5% | 8.089 | 8.156 | -0.8% | 1.86x | 2.69x |
| causal_s8k | PASS | 2.421 | 1.779 | +36.1% | 14.530 | 14.502 | +0.2% | 1.74x | 2.54x |
| window1k_s8k | PASS | 0.644 | 0.572 | +12.6% | 2.657 | 2.632 | +1.0% | 1.87x | 1.96x |
| band1k_s8k | PASS | 1.007 | 0.881 | +14.3% | 4.400 | 4.411 | -0.2% | 1.63x | 1.23x |
| prefix_lm_s8k | PASS | 2.563 | 2.186 | +17.2% | 14.365 | 14.347 | +0.1% | 2.01x | 2.00x |
| inkling_global_1doc | PASS | 2.240 | 2.067 | +8.4% | 11.389 | 11.373 | +0.1% | 1.12x | 2.06x |
| inkling_global_5doc | PASS | 0.854 | 0.814 | +5.0% | 4.825 | 4.718 | +2.3% | 0.85x | 1.94x |
| inkling_local_1doc | PASS | 0.497 | 0.460 | +8.0% | 1.990 | 1.999 | -0.4% | 1.03x | 1.65x |
| inkling_local_5doc | PASS | 0.553 | 0.503 | +9.8% | 2.678 | 2.612 | +2.5% | 1.14x | 1.89x |
| inkling_small_global_1doc | PASS | 1.282 | 1.155 | +11.0% | 6.254 | 6.257 | -0.0% | 0.93x | 2.19x |
| inkling_small_global_5doc | PASS | 0.623 | 0.558 | +11.6% | 2.634 | 2.641 | -0.3% | 1.10x | 1.59x |
| inkling_small_local_1doc | PASS | 0.332 | 0.313 | +6.0% | 1.157 | 1.154 | +0.2% | 1.12x | 1.41x |
| inkling_small_local_5doc | PASS | 0.382 | 0.356 | +7.3% | 1.530 | 1.508 | +1.4% | 1.23x | 1.58x |

- Forward geomean: 104.852 -> 119.247 TFLOPS (+13.7%)
- Backward geomean: 56.123 -> 56.382 TFLOPS (+0.5%)

## Decision

`ACCEPTED`

## Attribution

Forward +5% to +36% (dense causal +36%, Inkling +5-12%): half the MFMA instructions and K / Q fragment loads at twice the width. The P . V V^T reads stay element-wise (8 per fragment now).

## Real-training transfer check
- Bucket: K1 (kernel-internal / launch configuration); no cache
- Estimated real-training gain: same as benchmark
- Decision: ACCEPT-as-real

## Next direction

The same MFMA in the backward (dQ and dK/dV); then V^T via ds_read_b64_tr_b16 and double-buffered K/V staging with gfx950's 160 KB LDS.
