# Round 13 — ACCEPTED: transpose reads for the backward's column views (dQ, dK, dV)

## Hypothesis

The backward's three products that reduce over an accumulator's rows (dQ = dS . K, dK = dS^T . Q, dV = P^T . dO) read A fragments of the transposed LDS views one 16-bit element at a time (8 per fragment), as the forward's P . V did before round 8.

## Single change

flash_bwd.py _Ops.a_from_cols_tr (gfx950, k_step 16): two LDSReadTrans16_64b reads per A fragment; with the bit-2/3 reduction order, read h covers stored rows 16 step + 4 (lane // 32) + 8 h + {0..3}; addresses through the tile's chunk ^ (row & 7) swizzle. Used for kt_cols (dQ), dot_cols (dV), qt_cols (dK). gfx942 keeps the element reads.

## Results

- Validation: full (13 shapes) on a17-31's 8 GPUs; each shape's reference and candidate ran on the same GPU
  (`artifacts/validation.log`, gpu map at the end); tests before benchmarks.
- Raw artifacts: `artifacts/benchmark.csv`, `artifacts/round12_reference_same_gpu.csv`

| shape | Check | ref fwd ms | fwd ms | fwd change | ref bwd ms | bwd ms | bwd change | fwd vs Triton | bwd vs Triton |
|---|---|---|---|---|---|---|---|---|---|
| causal_s4k | PASS | 1.001 | 1.001 | -0.0% | 5.410 | 3.942 | +37.2% | 1.65x | 1.30x |
| causal_s8k | PASS | 1.553 | 1.746 | -11.0% | 9.648 | 7.261 | +32.9% | 1.71x | 1.28x |
| window1k_s8k | PASS | 0.493 | 0.543 | -9.2% | 1.922 | 1.467 | +31.1% | 1.24x | 1.05x |
| band1k_s8k | PASS | 0.762 | 0.769 | -0.9% | 3.118 | 2.282 | +36.6% | 1.43x | 0.62x |
| prefix_lm_s8k | PASS | 1.751 | 1.736 | +0.9% | 9.663 | 6.912 | +39.8% | 1.62x | 0.97x |
| inkling_global_1doc | PASS | 1.626 | 1.632 | -0.3% | 9.020 | 7.047 | +28.0% | 0.88x | 1.28x |
| inkling_global_5doc | PASS | 0.767 | 0.631 | +21.5% | 4.047 | 3.553 | +13.9% | 0.92x | 1.47x |
| inkling_local_1doc | PASS | 0.435 | 0.433 | +0.5% | 1.742 | 1.855 | -6.1% | 0.97x | 1.54x |
| inkling_local_5doc | PASS | 0.474 | 0.473 | +0.1% | 2.250 | 2.228 | +1.0% | 1.07x | 1.62x |
| inkling_small_global_1doc | PASS | 0.939 | 0.938 | +0.1% | 4.955 | 3.772 | +31.4% | 0.76x | 1.32x |
| inkling_small_global_5doc | PASS | 0.496 | 0.483 | +2.6% | 2.230 | 1.997 | +11.7% | 0.91x | 1.20x |
| inkling_small_local_1doc | PASS | 0.308 | 0.304 | +1.1% | 1.059 | 1.044 | +1.4% | 1.09x | 1.30x |
| inkling_small_local_5doc | PASS | 0.342 | 0.342 | -0.0% | 1.321 | 1.328 | -0.5% | 1.18x | 1.39x |

- Forward geomean: 134.716 -> 134.943 TFLOPS (+0.2%)
- Backward geomean: 71.942 -> 85.437 TFLOPS (+18.8%)

## Decision

`ACCEPTED`

## Attribution

Backward geomean +18.8%: dense +31-40% (causal 8K 9.65 -> 7.26 ms; band and prefix now faster than Triton), Inkling global +12-31%. inkling_local_1doc's single-run -6.1% re-measured 3x alternating on one GPU: +4.2% (artifacts/noise_recheck_local.log). The forward kernel is unchanged; its +-10-20% swings on two shapes are noise.

## Real-training transfer check
- Bucket: K1 (kernel-internal / launch configuration); no cache
- Estimated real-training gain: same as benchmark
- Decision: ACCEPT-as-real

## Next direction

The chunk ^ (row & 7) swizzle leaves the 4 rows of a transpose read 2-way conflicted (rows 0/1 and 2/3 share a 32-byte span); a bit-permuted XOR (f(r) = (r&3)<<1 | r>>2&1) would keep the row reads conflict-free and fix it. Then batch each step's fragment reads before the MFMAs (forward round 10).
