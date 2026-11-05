# Round 13 — ROLLED BACK: row max via v_max_f32 (fx.maxnumf)

## Hypothesis

After round 12 the forward's unmasked KV-tile loop still has 661 VALU per tile; the row max is a compare + select per element (66 v_cmp_gt_f32 + ~130 v_cndmask). fx.maxnumf lowers to one v_max_f32. Expected: ~100 fewer VALU per tile, faster forward on every shape.

## Single change

softmax.py _max -> fx.maxnumf.

## Results

- Validation: full (13 shapes) on a17-31's 8 GPUs; each shape's reference and candidate ran on the same GPU
  (`artifacts/validation.log`, gpu map at the end); tests before benchmarks.
- Raw artifacts: `artifacts/benchmark.csv`, `artifacts/round12_reference_same_gpu.csv`

| shape | Check | ref fwd ms | fwd ms | fwd change | ref bwd ms | bwd ms | bwd change | fwd vs Triton | bwd vs Triton |
|---|---|---|---|---|---|---|---|---|---|
| causal_s4k | PASS | 1.768 | 1.863 | -5.1% | 8.460 | 8.472 | -0.1% | 1.67x | 1.80x |
| causal_s8k | PASS | 2.816 | 2.833 | -0.6% | 12.308 | 12.331 | -0.2% | 1.59x | 1.37x |
| window1k_s8k | PASS | 0.899 | 0.891 | +1.0% | 3.146 | 3.153 | -0.2% | 1.37x | 1.36x |
| band1k_s8k | PASS | 1.443 | 1.422 | +1.5% | 5.309 | 5.339 | -0.6% | 1.47x | 1.07x |
| prefix_lm_s8k | PASS | 2.970 | 2.992 | -0.7% | 12.180 | 12.158 | +0.2% | 1.57x | 1.29x |
| inkling_global_1doc | PASS | 2.452 | 2.455 | -0.1% | 11.464 | 11.655 | -1.6% | 0.76x | 1.44x |
| inkling_global_5doc | PASS | 0.966 | 0.969 | -0.4% | 5.467 | 5.457 | +0.2% | 0.78x | 1.65x |
| inkling_local_1doc | PASS | 0.672 | 0.663 | +1.3% | 2.887 | 2.857 | +1.0% | 0.80x | 1.75x |
| inkling_local_5doc | PASS | 0.639 | 0.633 | +1.0% | 2.972 | 2.876 | +3.3% | 0.79x | 1.87x |
| inkling_small_global_1doc | PASS | 1.421 | 1.394 | +1.9% | 6.553 | 6.523 | +0.5% | 0.71x | 1.45x |
| inkling_small_global_5doc | PASS | 0.748 | 0.739 | +1.3% | 3.067 | 3.070 | -0.1% | 0.85x | 1.27x |
| inkling_small_local_1doc | PASS | 0.460 | 0.450 | +2.2% | 1.701 | 1.682 | +1.1% | 0.90x | 1.40x |
| inkling_small_local_5doc | PASS | 0.452 | 0.441 | +2.6% | 1.724 | 1.659 | +3.9% | 0.88x | 1.51x |

- Forward geomean: 86.141 -> 86.511 TFLOPS (+0.4%)
- Backward geomean: 50.462 -> 50.745 TFLOPS (+0.6%)

## Decision

`ROLLED BACK`

## Attribution

Interior loop VALU 661 -> 612, but the masked loop gained 65 canonicalizing v_mul_f32 (IEEE-mode maxnum quieting) and the forward did not speed up: geomean +0.4%, causal_s4k -5.1% (rule: >= 5%). VALU count is not the binding limit by itself: _row_reduce folds the 32 scores serially (acc = op(acc, v)), a 32-deep dependency chain for max and another for sum per tile, which 2 waves/SIMD cannot hide.

## Real-training transfer check
- Bucket: K1 (kernel-internal / launch configuration); no cache
- Estimated real-training gain: same as benchmark
- Decision: REJECT (performance)

## Next direction

Round 14: pairwise (tree) row reductions in softmax._row_reduce (chain 32 -> 5), keeping compare + select.

## Rollback Analysis
- Change made: row max with fx.maxnumf.
- Expected effect: ~100 fewer VALU per tile.
- Actual effect: -49 VALU in the interior loop, +65 v_mul_f32 canonicalizes in the masked loop; time unchanged / causal_s4k -5.1%.
- Root cause: under IEEE mode maxnum needs canonicalized inputs; and the reduction's serial dependency chain, not its instruction count, sets the time.
- Lesson learned: shorten dependency chains (tree reductions) before trimming instruction counts.
