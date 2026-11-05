# Round 12 — ACCEPTED: unmasked interior KV tiles in the forward

## Hypothesis

ISA of the forward's KV-tile loop (causal_s8k, round-11 kernels, profiles/fwd_round11_isa.s): per 64-key tile 64 MFMA vs 816 VALU, 135 SALU, 103 s_waitcnt, 158 ds_read: the loop is VALU-bound (~3.3k VALU cycles vs ~2k MFMA cycles). Much of the VALU is the per-score mask (positions, causal / window / seqlen compares, selects, masked softmax). Tiles whose keys are all kept for every query of the block need none of it; Triton / FA4 split their loops the same way. Expected: causal / window / Inkling forward faster; block-list masks (band, prefix) unchanged.

## Single change

block_info.py `get_n_block_interior` (blocks wholly kept by causal / local and before the sequence end); flash_fwd.py runs masked [n_min, n_lo), unmasked [n_lo, n_hi), masked [n_hi, n_max) when there is no mask_mod; softmax.py online_softmax(keep=None) skips the selects.

## Results

- Validation: full (13 shapes) on a17-31's 8 GPUs; each shape's reference and candidate ran on the same GPU
  (`artifacts/validation.log`, gpu map at the end); tests before benchmarks.
- Raw artifacts: `artifacts/benchmark.csv`, `artifacts/round11_reference_same_gpu.csv`

| shape | Check | ref fwd ms | fwd ms | fwd change | ref bwd ms | bwd ms | bwd change | fwd vs Triton | bwd vs Triton |
|---|---|---|---|---|---|---|---|---|---|
| causal_s4k | PASS | 1.903 | 1.775 | +7.2% | 8.409 | 8.470 | -0.7% | 1.69x | 1.82x |
| causal_s8k | PASS | 3.016 | 2.837 | +6.3% | 12.363 | 12.518 | -1.2% | 1.60x | 1.38x |
| window1k_s8k | PASS | 0.978 | 0.900 | +8.7% | 3.104 | 3.126 | -0.7% | 1.35x | 1.39x |
| band1k_s8k | PASS | 1.433 | 1.421 | +0.8% | 5.281 | 5.276 | +0.1% | 1.47x | 1.07x |
| prefix_lm_s8k | PASS | 2.998 | 2.969 | +1.0% | 12.178 | 12.180 | -0.0% | 1.56x | 1.28x |
| inkling_global_1doc | PASS | 2.530 | 2.444 | +3.5% | 11.515 | 11.526 | -0.1% | 0.76x | 1.43x |
| inkling_global_5doc | PASS | 0.973 | 0.985 | -1.3% | 5.465 | 5.463 | +0.0% | 0.79x | 1.63x |
| inkling_local_1doc | PASS | 0.667 | 0.659 | +1.3% | 2.719 | 2.731 | -0.4% | 0.78x | 1.63x |
| inkling_local_5doc | PASS | 0.635 | 0.629 | +0.9% | 2.825 | 2.853 | -1.0% | 0.79x | 1.86x |
| inkling_small_global_1doc | PASS | 1.491 | 1.417 | +5.2% | 6.406 | 6.408 | -0.0% | 0.72x | 1.42x |
| inkling_small_global_5doc | PASS | 0.756 | 0.738 | +2.4% | 3.065 | 3.004 | +2.0% | 0.85x | 1.25x |
| inkling_small_local_1doc | PASS | 0.462 | 0.455 | +1.6% | 1.668 | 1.776 | -6.1% | 0.90x | 1.49x |
| inkling_small_local_5doc | PASS | 0.454 | 0.442 | +2.7% | 1.737 | 1.677 | +3.6% | 0.88x | 1.53x |

- Forward geomean: 84.034 -> 86.612 TFLOPS (+3.1%)
- Backward geomean: 51.098 -> 50.905 TFLOPS (-0.4%)

## Decision

`ACCEPTED`

## Attribution

Causal / window forward +6-9%: the interior tiles drop the mask VALU; each causal query block still has 2-3 masked diagonal tiles. Inkling +1-5% (its rel-bias score_mod work remains per score). Band / prefix use block lists (unchanged path). The backward kernels are untouched; inkling_small_local_1doc's -6.1% backward was re-measured 3x alternating on one GPU: -1.3%, noise (artifacts/noise_recheck_inkling_small_local_1doc.log).

## Real-training transfer check
- Bucket: K1 (kernel-internal / launch configuration); no cache
- Estimated real-training gain: same as benchmark
- Decision: ACCEPT-as-real

## Next direction

Re-dump the ISA with interior tiles to see what VALU remains per tile (online softmax, P conversion to bf16, O rescale through accvgpr moves); apply the interior split to block-list full blocks (band / prefix).
