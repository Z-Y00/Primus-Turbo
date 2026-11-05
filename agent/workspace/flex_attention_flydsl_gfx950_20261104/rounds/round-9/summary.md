# Round 9 — ROLLED BACK: bare v_exp_f32 (rocdl.exp2) in the online softmax

## Hypothesis

The forward's KV-tile loop runs far more VALU than the online softmax needs; exp2 lowers with range fix-ups (v_ldexp + compares + selects) although every argument is <= 0. rocdl.exp2 is the bare v_exp_f32. Expected: ~2-3 VALU fewer per score, faster forward.

## Single change

softmax.py online_softmax: probabilities and rescale via rocdl.exp2 (bare v_exp_f32).

## Results

- Validation: full (13 shapes) on a17-31's 8 GPUs; each shape's reference and candidate ran on the same GPU
  (`artifacts/validation.log`, gpu map at the end); tests before benchmarks.
- Raw artifacts: `artifacts/benchmark.csv`, `artifacts/round8_reference_same_gpu.csv`

| shape | Check | ref fwd ms | fwd ms | fwd change | ref bwd ms | bwd ms | bwd change | fwd vs Triton | bwd vs Triton |
|---|---|---|---|---|---|---|---|---|---|
| causal_s4k | PASS | 1.013 | 1.001 | +1.3% | 6.985 | 6.935 | +0.7% | 1.66x | 2.31x |
| causal_s8k | PASS | 1.562 | 1.549 | +0.8% | 11.996 | 12.069 | -0.6% | 1.52x | 2.14x |
| window1k_s8k | PASS | 0.503 | 0.495 | +1.7% | 2.282 | 2.285 | -0.1% | 1.61x | 1.66x |
| band1k_s8k | PASS | 0.758 | 0.745 | +1.8% | 3.753 | 3.786 | -0.9% | 1.37x | 1.04x |
| prefix_lm_s8k | PASS | 1.779 | 1.758 | +1.2% | 11.910 | 11.933 | -0.2% | 1.62x | 1.66x |
| inkling_global_1doc | PASS | 1.736 | 1.726 | +0.6% | 10.604 | 10.606 | -0.0% | 0.94x | 1.92x |
| inkling_global_5doc | PASS | 0.657 | 0.649 | +1.2% | 4.539 | 4.539 | -0.0% | 0.95x | 1.90x |
| inkling_local_1doc | PASS | 0.437 | 0.434 | +0.5% | 1.863 | 1.910 | -2.5% | 0.98x | 1.57x |
| inkling_local_5doc | PASS | 0.482 | 0.474 | +1.7% | 2.566 | 2.489 | +3.1% | 1.07x | 1.82x |
| inkling_small_global_1doc | PASS | 0.993 | 0.985 | +0.9% | 5.917 | 5.889 | +0.5% | 0.80x | 2.07x |
| inkling_small_global_5doc | PASS | 0.508 | 0.498 | +2.0% | 2.530 | 2.487 | +1.7% | 1.00x | 1.50x |
| inkling_small_local_1doc | PASS | 0.302 | 0.300 | +0.5% | 1.121 | 1.131 | -1.0% | 1.06x | 1.31x |
| inkling_small_local_5doc | PASS | 0.338 | 0.339 | -0.2% | 1.405 | 1.437 | -2.2% | 1.17x | 1.49x |

- Forward geomean: 134.417 -> 135.852 TFLOPS (+1.1%)
- Backward geomean: 61.982 -> 61.908 TFLOPS (-0.1%)

## Decision

`ROLLED BACK`

## Attribution

VALU per unmasked tile fell to 280 (masked 472), yet the forward moved +1.1% geomean, and 3 alternating re-measures on one GPU gave -0.4% to +0.6% (artifacts/noise_recheck.log): the forward is not VALU-bound. The ISA shows each P . V MFMA behind its own s_waitcnt lgkmcnt(0) on its two transpose reads, with nothing issued ahead: the loop pays LDS latency per MFMA.

## Real-training transfer check
- Bucket: K1 (kernel-internal / launch configuration); no cache
- Estimated real-training gain: same as benchmark
- Decision: REJECT (performance)

## Next direction

Round 10: in P . V, issue the transpose reads of all d blocks of a key step before their MFMAs.

## Rollback Analysis
- Change made: rocdl.exp2 for the softmax exponentials.
- Expected effect: fewer VALU, faster forward.
- Actual effect: ~40% fewer VALU in the unmasked loop, no measurable time change.
- Root cause: VALU issue is not the forward's limit on gfx950; per-MFMA LDS waits in P . V are.
- Lesson learned: check the wait structure (s_waitcnt placement) before cutting instruction counts.
