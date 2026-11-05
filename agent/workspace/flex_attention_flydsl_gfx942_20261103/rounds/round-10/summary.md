# Round 10 — ACCEPTED: work-aware dK/dV split heuristic

## Hypothesis

Round 9 splits the GQA group only until each CU has one dK/dV CTA; its first attempt showed causal 8K gains +24% at split 4 vs +7% at split 2, while window lost at more splits. The right split depends on work per CTA: keep splitting up to 2 CTAs/CU while each CTA keeps >= 128 (query tile x head) iterations (estimated from the mask: causal ~ half the query tiles, window ~ (window + key tile) / query tile, else all).

## Single change

flash_bwd.py `_dkdv_split(ctas, seqlen_q, window_left, window_right)` with MIN_SPLIT_WORK = 128; causal / prefix 8K now split 4 (was 2), other shapes keep their split.

## Results

- Validation: full (13 shapes) on a17-31's 8 GPUs; each shape's reference and candidate ran on the same GPU
  (`artifacts/validation.log`, gpu map at the end); tests before benchmarks.
- Raw artifacts: `artifacts/benchmark.csv`, `artifacts/round9_reference_same_gpu.csv`

| shape | Check | ref fwd ms | fwd ms | fwd change | ref bwd ms | bwd ms | bwd change | fwd vs Triton | bwd vs Triton |
|---|---|---|---|---|---|---|---|---|---|
| causal_s4k | PASS | 1.897 | 1.881 | +0.8% | 8.425 | 8.423 | +0.0% | 1.81x | 1.79x |
| causal_s8k | PASS | 3.092 | 3.030 | +2.1% | 14.326 | 12.382 | +15.7% | 1.69x | 1.38x |
| window1k_s8k | PASS | 0.948 | 0.946 | +0.2% | 3.149 | 3.144 | +0.1% | 1.43x | 1.36x |
| band1k_s8k | PASS | 1.418 | 1.412 | +0.4% | 5.268 | 5.329 | -1.1% | 1.47x | 1.07x |
| prefix_lm_s8k | PASS | 3.030 | 3.039 | -0.3% | 14.001 | 12.115 | +15.6% | 1.60x | 1.29x |
| inkling_global_1doc | PASS | 2.607 | 2.587 | +0.8% | 12.561 | 12.378 | +1.5% | 0.80x | 1.54x |
| inkling_global_5doc | PASS | 1.010 | 0.988 | +2.3% | 5.846 | 5.793 | +0.9% | 0.79x | 1.75x |
| inkling_local_1doc | PASS | 0.671 | 0.667 | +0.6% | 2.994 | 2.973 | +0.7% | 0.80x | 1.83x |
| inkling_local_5doc | PASS | 0.636 | 0.634 | +0.2% | 3.097 | 3.083 | +0.5% | 0.80x | 1.98x |
| inkling_small_global_1doc | PASS | 1.509 | 1.511 | -0.1% | 7.098 | 7.060 | +0.5% | 0.77x | 1.55x |
| inkling_small_global_5doc | PASS | 0.771 | 0.775 | -0.5% | 3.260 | 3.232 | +0.9% | 0.90x | 1.34x |
| inkling_small_local_1doc | PASS | 0.463 | 0.459 | +0.9% | 1.945 | 1.842 | +5.6% | 0.90x | 1.55x |
| inkling_small_local_5doc | PASS | 0.455 | 0.451 | +0.9% | 1.865 | 1.876 | -0.6% | 0.89x | 1.70x |

- Forward geomean: 83.385 -> 83.912 TFLOPS (+0.6%)
- Backward geomean: 47.198 -> 48.593 TFLOPS (+3.0%)

## Decision

`ACCEPTED`

## Attribution

Causal and prefix 8K carry ~512 head-iterations per unsplit CTA, so 4-way splitting still leaves 128 per CTA and doubles the CTAs per CU (1024 for 304 CUs), hiding the causal tail imbalance; window / band / Inkling keep their splits and are unchanged (within noise; inkling_small_local_1doc +5.6% is noise, its split did not change).

## Real-training transfer check
- Bucket: K1 (kernel-internal / launch configuration); no cache
- Estimated real-training gain: same as benchmark
- Decision: ACCEPT-as-real

## Next direction

Round 11: the dQ kernel's per-score cost on the Inkling local layers (bias gather + hook store), now the largest Inkling gap (1.8-2.0x Triton).
