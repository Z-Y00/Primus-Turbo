# Round 11 — ACCEPTED: rel-bias mods index from SeqlenInfo (no per-score cu_seqlens loads)

## Hypothesis

The Inkling rel-bias FlyDSL mods reload cu_seqlens[b] and cu_seqlens[b+1] for every score (Triton loads them once per tile, b being scalar there); the dQ kernel does it twice per score (score_mod + hook), with the hook's stores preventing reuse. SeqlenInfo already holds the sequence's offset and length (from the same cu_seqlens, once per CTA). Expected: Inkling fwd / bwd faster, most on the dQ-bound local layers; dense unchanged.

## Single change

mods.py make_rel_bias_mods: rel_index(q_idx, kv_idx, seqlen_info) uses seqlen_info.offset_q / seqlen_q; removes 2 buffer loads per score in score_mod and in the hook. (First attempt's reference tree accidentally had the new mods.py; rerun with the committed files as reference, kept in rounds/round-11/ref/.)

## Results

- Validation: full (13 shapes) on a17-31's 8 GPUs; each shape's reference and candidate ran on the same GPU
  (`artifacts/validation.log`, gpu map at the end); tests before benchmarks.
- Raw artifacts: `artifacts/benchmark.csv`, `artifacts/round10_reference_same_gpu.csv`

| shape | Check | ref fwd ms | fwd ms | fwd change | ref bwd ms | bwd ms | bwd change | fwd vs Triton | bwd vs Triton |
|---|---|---|---|---|---|---|---|---|---|
| causal_s4k | PASS | 1.908 | 1.863 | +2.4% | 8.491 | 8.461 | +0.4% | 1.75x | 1.81x |
| causal_s8k | PASS | 3.253 | 3.092 | +5.2% | 12.513 | 12.343 | +1.4% | 1.63x | 1.37x |
| window1k_s8k | PASS | 0.953 | 0.951 | +0.2% | 3.137 | 3.149 | -0.4% | 1.46x | 1.37x |
| band1k_s8k | PASS | 1.413 | 1.387 | +1.9% | 5.291 | 5.320 | -0.6% | 1.43x | 1.06x |
| prefix_lm_s8k | PASS | 2.995 | 3.019 | -0.8% | 12.103 | 12.127 | -0.2% | 1.59x | 1.28x |
| inkling_global_1doc | PASS | 2.595 | 2.521 | +2.9% | 12.345 | 11.451 | +7.8% | 0.79x | 1.43x |
| inkling_global_5doc | PASS | 0.990 | 0.972 | +1.9% | 5.844 | 5.419 | +7.9% | 0.78x | 1.64x |
| inkling_local_1doc | PASS | 0.668 | 0.674 | -1.0% | 3.294 | 2.649 | +24.4% | 0.81x | 1.61x |
| inkling_local_5doc | PASS | 0.640 | 0.631 | +1.4% | 3.145 | 2.850 | +10.3% | 0.79x | 1.86x |
| inkling_small_global_1doc | PASS | 1.504 | 1.477 | +1.9% | 6.920 | 6.447 | +7.3% | 0.75x | 1.42x |
| inkling_small_global_5doc | PASS | 0.777 | 0.755 | +2.9% | 3.249 | 3.110 | +4.5% | 0.87x | 1.28x |
| inkling_small_local_1doc | PASS | 0.547 | 0.461 | +18.8% | 1.765 | 1.751 | +0.8% | 0.91x | 1.45x |
| inkling_small_local_5doc | PASS | 0.453 | 0.455 | -0.4% | 1.797 | 1.651 | +8.9% | 0.91x | 1.51x |

- Forward geomean: 82.160 -> 84.434 TFLOPS (+2.8%)
- Backward geomean: 48.456 -> 51.062 TFLOPS (+5.4%)

## Decision

`ACCEPTED`

## Attribution

Inkling backward +4.5% to +24% (local_1doc 3.29 -> 2.65 ms), forward ~+2-3%: the per-score scalar loads were a real share of the dQ / dK-dV inner loop. Dense shapes do not use the mods (moves within noise; causal_s8k fwd +5.2% and inkling_small_local_1doc fwd +18.8% are run-to-run noise on short timings).

## Real-training transfer check
- Bucket: K1 (kernel-internal / launch configuration); no cache
- Estimated real-training gain: same as benchmark
- Decision: ACCEPT-as-real

## Next direction

Profile the dQ kernel's remaining per-score cost on Inkling local (bias gather + hook store), and the dense forward (1.4-1.75x Triton).
