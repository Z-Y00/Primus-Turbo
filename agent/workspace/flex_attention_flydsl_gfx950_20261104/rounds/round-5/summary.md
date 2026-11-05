# Round 5 — ROLLED BACK: transpose reads from a row-XOR-swizzled V tile

## Hypothesis

Round 4's transpose reads regressed causal by 6-7%, attributed to bank conflicts: a 16-lane read covers 4 V rows 256 B apart. XOR-swizzling V's 16-byte chunks by row (chunk ^= row & 7), as K is, should spread them.

## Single change

flash_fwd.py: with VTR, V staging stores chunk (row, c) at c ^ (row & 7); the transpose-read addresses apply the same XOR.

## Results

- Validation: full (13 shapes) on a17-31's 8 GPUs; each shape's reference and candidate ran on the same GPU
  (`artifacts/validation.log`, gpu map at the end); tests before benchmarks.
- Raw artifacts: `artifacts/benchmark.csv`, `artifacts/round3_reference_same_gpu.csv`

| shape | Check | ref fwd ms | fwd ms | fwd change | ref bwd ms | bwd ms | bwd change | fwd vs Triton | bwd vs Triton |
|---|---|---|---|---|---|---|---|---|---|
| causal_s4k | PASS | 1.152 | 1.238 | -6.9% | 6.943 | 6.921 | +0.3% | 2.01x | 2.27x |
| causal_s8k | PASS | 1.803 | 1.906 | -5.4% | 12.014 | 12.057 | -0.4% | 1.88x | 2.13x |
| window1k_s8k | PASS | 0.580 | 0.554 | +4.7% | 2.292 | 2.283 | +0.4% | 1.55x | 1.66x |
| band1k_s8k | PASS | 0.914 | 0.834 | +9.6% | 3.781 | 3.795 | -0.4% | 1.55x | 1.05x |
| prefix_lm_s8k | PASS | 2.198 | 2.002 | +9.8% | 11.911 | 11.979 | -0.6% | 1.82x | 1.67x |
| inkling_global_1doc | PASS | 2.073 | 1.916 | +8.2% | 10.624 | 10.631 | -0.1% | 1.04x | 1.92x |
| inkling_global_5doc | PASS | 0.713 | 0.681 | +4.7% | 4.554 | 4.513 | +0.9% | 0.99x | 1.90x |
| inkling_local_1doc | PASS | 0.470 | 0.455 | +3.3% | 1.889 | 1.858 | +1.6% | 1.03x | 1.56x |
| inkling_local_5doc | PASS | 0.511 | 0.498 | +2.5% | 2.544 | 2.482 | +2.5% | 1.12x | 1.79x |
| inkling_small_global_1doc | PASS | 1.161 | 1.112 | +4.4% | 5.914 | 5.918 | -0.1% | 0.90x | 2.06x |
| inkling_small_global_5doc | PASS | 0.567 | 0.558 | +1.6% | 2.509 | 2.494 | +0.6% | 1.13x | 1.51x |
| inkling_small_local_1doc | PASS | 0.319 | 0.309 | +3.4% | 1.104 | 1.105 | -0.1% | 1.11x | 1.35x |
| inkling_small_local_5doc | PASS | 0.370 | 0.352 | +5.1% | 1.471 | 1.425 | +3.3% | 1.22x | 1.50x |

- Forward geomean: 118.691 -> 122.669 TFLOPS (+3.4%)
- Backward geomean: 61.795 -> 62.175 TFLOPS (+0.6%)

## Decision

`ROLLED BACK`

## Attribution

Causal still -5 to -7%, and Inkling gains shrank. Profile (causal_s8k fwd, profiles/round3_4_5_fwd_causal_s8k.log): rounds 4 and 5 both cut SQ_INSTS_LDS 81 M -> 30 M and LDS waits 86 M -> 24 M, but SQ_LDS_BANK_CONFLICT went 34 M -> 136 M in both, unchanged by the swizzle. A transpose read's 16 lanes cover 4 consecutive rows x 32 B (2 adjacent chunks); chunk ^ (row & 7) maps rows 0 and 1 onto the same chunk pair (swapped), likewise rows 2 and 3, so the conflict stays.

## Real-training transfer check
- Bucket: K1 (kernel-internal / launch configuration); no cache
- Estimated real-training gain: same as benchmark
- Decision: REJECT (performance)

## Next direction

Round 6: XOR by (row & 3) << 1, which sends the 4 rows of a transpose read to 4 different chunk pairs (all 32 banks).

## Rollback Analysis
- Change made: chunk ^= row & 7 on V with transpose reads.
- Expected effect: conflict-free transpose reads.
- Actual effect: identical conflict count (136 M cycles) to round 4.
- Root cause: the XOR pattern pairs rows 0/1 and 2/3 onto the same 32-byte span; the swizzle must vary the chunk *pair*.
- Lesson learned: derive the swizzle from the read's footprint (4 rows x 32 B per 16 lanes), not copy K's.
