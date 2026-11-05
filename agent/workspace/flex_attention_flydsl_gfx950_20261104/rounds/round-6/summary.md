# Round 6 — ROLLED BACK: transpose reads from a V tile swizzled by (row & 3) << 1

## Hypothesis

Round 5's swizzle left the transpose-read conflicts untouched (rows 0/1 and 2/3 shared a 32-byte span). chunk ^= (row & 3) << 1 puts the 4 rows a 16-lane transpose read covers on 4 different chunk pairs.

## Single change

flash_fwd.py: round 4's transpose reads; V staging stores and transpose-read addresses XOR the chunk with (row & 3) * 2.

## Results

- Validation: full (13 shapes) on a17-31's 8 GPUs; each shape's reference and candidate ran on the same GPU
  (`artifacts/validation.log`, gpu map at the end); tests before benchmarks.
- Raw artifacts: `artifacts/benchmark.csv`, `artifacts/round3_reference_same_gpu.csv`

| shape | Check | ref fwd ms | fwd ms | fwd change | ref bwd ms | bwd ms | bwd change | fwd vs Triton | bwd vs Triton |
|---|---|---|---|---|---|---|---|---|---|
| causal_s4k | PASS | 1.151 | 1.218 | -5.5% | 6.876 | 6.925 | -0.7% | 1.97x | 2.36x |
| causal_s8k | PASS | 1.788 | 1.864 | -4.1% | 12.047 | 12.111 | -0.5% | 1.87x | 2.11x |
| window1k_s8k | PASS | 0.667 | 0.548 | +21.8% | 2.303 | 2.283 | +0.9% | 1.55x | 1.66x |
| band1k_s8k | PASS | 0.897 | 0.802 | +11.9% | 3.770 | 3.781 | -0.3% | 1.50x | 1.04x |
| prefix_lm_s8k | PASS | 2.202 | 1.988 | +10.8% | 11.943 | 11.937 | +0.0% | 1.85x | 1.66x |
| inkling_global_1doc | PASS | 2.081 | 1.740 | +19.6% | 10.616 | 10.611 | +0.0% | 0.95x | 1.94x |
| inkling_global_5doc | PASS | 0.715 | 0.650 | +10.0% | 4.571 | 4.541 | +0.7% | 0.94x | 1.90x |
| inkling_local_1doc | PASS | 0.468 | 0.454 | +3.0% | 1.856 | 1.868 | -0.6% | 1.02x | 1.56x |
| inkling_local_5doc | PASS | 0.509 | 0.504 | +1.1% | 2.502 | 2.530 | -1.1% | 1.13x | 1.82x |
| inkling_small_global_1doc | PASS | 1.158 | 0.995 | +16.4% | 5.932 | 5.907 | +0.4% | 0.80x | 2.08x |
| inkling_small_global_5doc | PASS | 0.567 | 0.506 | +12.2% | 2.495 | 2.537 | -1.7% | 1.01x | 1.54x |
| inkling_small_local_1doc | PASS | 0.318 | 0.309 | +2.7% | 1.109 | 1.128 | -1.7% | 1.11x | 1.37x |
| inkling_small_local_5doc | PASS | 0.361 | 0.353 | +2.2% | 1.433 | 1.421 | +0.8% | 1.22x | 1.48x |

- Forward geomean: 117.959 -> 126.842 TFLOPS (+7.5%)
- Backward geomean: 62.070 -> 61.888 TFLOPS (-0.3%)

## Decision

`ROLLED BACK`

## Attribution

Conflicts 136 M -> 68 M cycles (round 3: 34 M); window +22%, Inkling global +10-20%, band / prefix +11-12%, but causal 4K -5.5% (>= 5% rule), 8K -4.1%. The ISA (profiles/fwd_round6_isa.s) shows why causal loses even with 63% fewer LDS instructions: the loop is serialized. K/V staging is 8 x (buffer_load; s_waitcnt vmcnt(0); ds_write), each global load waited before the next is issued; every Q.K MFMA waits lgkmcnt(0) on its own K-fragment read and every P.V MFMA on its own two transpose reads, with no read-ahead. Causal runs the most tiles per CTA and pays this most.

## Real-training transfer check
- Bucket: K1 (kernel-internal / launch configuration); no cache
- Estimated real-training gain: same as benchmark
- Decision: REJECT (performance)

## Next direction

Round 7: issue all of a tile's staging loads before the LDS stores (on round 3's kernel); then re-apply this round's transpose reads (kernel_snapshot) and add fragment read-ahead.
