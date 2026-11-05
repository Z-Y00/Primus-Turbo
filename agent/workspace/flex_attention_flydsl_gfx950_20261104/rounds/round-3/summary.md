# Round 3 — ACCEPTED: 32x32x16 MFMA in the backward (dQ, dK/dV) on gfx950

## Hypothesis

Round 2's MFMA change applied to the backward. The backward feeds accumulators straight into the next MFMA's K in three places (dQ = dS . K over keys; dK, dV over queries), so the 16-deep step needs the accumulator-row order on those operands. K, Q and dO are also used as row operands, so instead of permuting rows at staging, only the transposed (column) views get the bit-2/3 swap as a layout.

## Single change

flash_bwd.py: `mfma_k` (16 on gfx950, 8 otherwise); _Ops builds the MFMA and its fragment copies from it (128-bit when 8 x 16-bit); `_k16_perm` gives kt_cols / qt_cols / dot_cols a (4,2,2,n/16):(1,8,4,16) reduction mode under the chunk swizzle; accumulator -> B fragments take KS/2 values. gfx942 unchanged.

## Results

- Validation: full (13 shapes) on a17-31's 8 GPUs; each shape's reference and candidate ran on the same GPU
  (`artifacts/validation.log`, gpu map at the end); tests before benchmarks.
- Raw artifacts: `artifacts/benchmark.csv`, `artifacts/round2_reference_same_gpu.csv`

| shape | Check | ref fwd ms | fwd ms | fwd change | ref bwd ms | bwd ms | bwd change | fwd vs Triton | bwd vs Triton |
|---|---|---|---|---|---|---|---|---|---|
| causal_s4k | PASS | 1.155 | 1.148 | +0.6% | 8.108 | 6.936 | +16.9% | 1.83x | 2.28x |
| causal_s8k | PASS | 1.784 | 1.793 | -0.5% | 14.565 | 12.115 | +20.2% | 1.75x | 2.13x |
| window1k_s8k | PASS | 0.574 | 0.579 | -0.9% | 2.681 | 2.300 | +16.5% | 1.76x | 1.66x |
| band1k_s8k | PASS | 0.889 | 0.892 | -0.3% | 4.401 | 3.771 | +16.7% | 1.67x | 1.06x |
| prefix_lm_s8k | PASS | 2.187 | 2.207 | -0.9% | 14.320 | 11.950 | +19.8% | 2.03x | 1.66x |
| inkling_global_1doc | PASS | 2.077 | 2.064 | +0.6% | 11.279 | 10.660 | +5.8% | 1.12x | 1.92x |
| inkling_global_5doc | PASS | 0.714 | 0.711 | +0.4% | 4.843 | 4.573 | +5.9% | 1.04x | 1.89x |
| inkling_local_1doc | PASS | 0.465 | 0.462 | +0.8% | 1.940 | 1.862 | +4.2% | 1.04x | 1.56x |
| inkling_local_5doc | PASS | 0.573 | 0.506 | +13.1% | 2.670 | 2.471 | +8.1% | 1.14x | 1.78x |
| inkling_small_global_1doc | PASS | 1.154 | 1.150 | +0.4% | 6.242 | 5.888 | +6.0% | 0.93x | 2.07x |
| inkling_small_global_5doc | PASS | 0.560 | 0.573 | -2.2% | 2.681 | 2.465 | +8.8% | 1.08x | 1.52x |
| inkling_small_local_1doc | PASS | 0.320 | 0.319 | +0.1% | 1.161 | 1.122 | +3.4% | 1.15x | 1.37x |
| inkling_small_local_5doc | PASS | 0.368 | 0.363 | +1.4% | 1.530 | 1.441 | +6.2% | 1.26x | 1.49x |

- Forward geomean: 118.372 -> 119.444 TFLOPS (+0.9%)
- Backward geomean: 56.142 -> 62.036 TFLOPS (+10.5%)

## Decision

`ACCEPTED`

## Attribution

Backward +3% to +20%: dense +17-20% (MFMA-heavy), Inkling +3-9% (more of its time is per-score bias / hook work and the dK/dV grid). Gradients match Triton (<= 3.9e-3 relative). inkling_local_5doc forward +13.1% is noise (forward unchanged).

## Real-training transfer check
- Bucket: K1 (kernel-internal / launch configuration); no cache
- Estimated real-training gain: same as benchmark
- Decision: ACCEPT-as-real

## Next direction

Reprofile on gfx950 (kernel times, counters, forward ISA) to rank the next gfx950 levers: V^T transpose reads, double-buffered staging with 160 KB LDS, larger tiles.
