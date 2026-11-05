# Round 14 — ROLLED BACK: pairwise row reductions in the online softmax

## Hypothesis

Round 13 suggested the 32-deep serial dependency chains of the per-tile row max and row sum (acc = op(acc, v)) limit the forward more than their instruction count. A pairwise tree cuts each chain to 5. Expected: faster forward on every shape.

## Single change

softmax.py _row_reduce: pairwise tree instead of a serial fold (compare + select max kept).

## Results

- Validation: full (13 shapes) on a17-31's 8 GPUs; each shape's reference and candidate ran on the same GPU
  (`artifacts/validation.log`, gpu map at the end); tests before benchmarks.
- Raw artifacts: `artifacts/benchmark.csv`, `artifacts/round12_reference_same_gpu.csv`

| shape | Check | ref fwd ms | fwd ms | fwd change | ref bwd ms | bwd ms | bwd change | fwd vs Triton | bwd vs Triton |
|---|---|---|---|---|---|---|---|---|---|
| causal_s4k | PASS | 1.773 | 1.773 | +0.0% | 8.467 | 8.487 | -0.2% | 1.70x | 1.81x |
| causal_s8k | PASS | 2.823 | 2.807 | +0.5% | 12.306 | 12.353 | -0.4% | 1.58x | 1.37x |
| window1k_s8k | PASS | 0.898 | 0.894 | +0.5% | 3.148 | 3.122 | +0.8% | 1.36x | 1.35x |
| band1k_s8k | PASS | 1.425 | 1.413 | +0.9% | 5.300 | 5.280 | +0.4% | 1.47x | 1.06x |
| prefix_lm_s8k | PASS | 3.022 | 3.007 | +0.5% | 12.193 | 12.169 | +0.2% | 1.55x | 1.28x |
| inkling_global_1doc | PASS | 2.439 | 2.442 | -0.1% | 11.520 | 11.484 | +0.3% | 0.76x | 1.43x |
| inkling_global_5doc | PASS | 0.970 | 0.961 | +0.9% | 5.338 | 5.319 | +0.4% | 0.78x | 1.61x |
| inkling_local_1doc | PASS | 0.672 | 0.666 | +0.9% | 2.653 | 2.981 | -11.0% | 0.80x | 1.83x |
| inkling_local_5doc | PASS | 0.641 | 0.631 | +1.6% | 2.881 | 2.623 | +9.9% | 0.80x | 1.70x |
| inkling_small_global_1doc | PASS | 1.397 | 1.406 | -0.6% | 6.388 | 6.419 | -0.5% | 0.72x | 1.44x |
| inkling_small_global_5doc | PASS | 0.768 | 0.739 | +3.9% | 3.089 | 3.017 | +2.4% | 0.85x | 1.27x |
| inkling_small_local_1doc | PASS | 0.460 | 0.455 | +1.2% | 1.655 | 1.723 | -4.0% | 0.90x | 1.44x |
| inkling_small_local_5doc | PASS | 0.449 | 0.444 | +0.9% | 1.736 | 1.692 | +2.6% | 0.89x | 1.53x |

- Forward geomean: 86.052 -> 86.778 TFLOPS (+0.8%)
- Backward geomean: 51.139 -> 51.121 TFLOPS (-0.0%)

## Decision

`ROLLED BACK`

## Attribution

Forward geomean +0.8% (every shape -0.6% to +3.9%): below the 2% noise threshold, so not accepted without 3 re-measures, and too small to be worth them. The reduction chains are not what limits the loop either; with 2 waves per SIMD and 64 MFMAs per tile the remaining cost is elsewhere (backward moved +/-10% on inkling_local shapes with an unchanged kernel: short backward timings are noisy).

## Real-training transfer check
- Bucket: K1 (kernel-internal / launch configuration); no cache
- Estimated real-training gain: same as benchmark
- Decision: REJECT (performance)

## Next direction

Software-pipelined K/V prefetch: today each tile's 8 global loads are issued and waited on right before the LDS stores, behind a barrier, so load latency is exposed every tile.
