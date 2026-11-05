# Round 4 — ROLLED BACK: V^T via ds_read_b64_tr_b16 (unswizzled V)

## Hypothesis

With 16-deep MFMA the forward's P . V A fragment is 8 V^T elements, read one 16-bit element at a time. gfx950's LDS transpose read (ds_read_b64_tr_b16) fetches a 4 x 16 block per 16 lanes and returns it transposed; two of them build the fragment straight from the row-major (row-permuted) V tile. Expected: fewer LDS instructions, faster forward.

## Single change

flash_fwd.py: VTR (gfx950 16-bit, KS 16): P . V A fragments from two LDSReadTrans16_64b copies (lane address: key + (lane % 16) // 4 + 8 * (lane // 32), d + 16 * ((lane % 32) // 16) + 4 * (lane % 4)); V tile unchanged.

## Results

- Validation: full (13 shapes) on a17-31's 8 GPUs; each shape's reference and candidate ran on the same GPU
  (`artifacts/validation.log`, gpu map at the end); tests before benchmarks.
- Raw artifacts: `artifacts/benchmark.csv`, `artifacts/round3_reference_same_gpu.csv`

| shape | Check | ref fwd ms | fwd ms | fwd change | ref bwd ms | bwd ms | bwd change | fwd vs Triton | bwd vs Triton |
|---|---|---|---|---|---|---|---|---|---|
| causal_s4k | PASS | 1.157 | 1.241 | -6.8% | 6.917 | 6.922 | -0.1% | 2.02x | 2.31x |
| causal_s8k | PASS | 1.899 | 1.912 | -0.7% | 12.040 | 12.002 | +0.3% | 1.91x | 2.11x |
| window1k_s8k | PASS | 0.568 | 0.541 | +5.0% | 2.284 | 2.280 | +0.2% | 1.53x | 1.57x |
| band1k_s8k | PASS | 0.906 | 0.832 | +8.9% | 3.783 | 3.794 | -0.3% | 1.53x | 1.04x |
| prefix_lm_s8k | PASS | 2.190 | 2.015 | +8.7% | 11.866 | 11.944 | -0.7% | 1.87x | 1.66x |
| inkling_global_1doc | PASS | 2.054 | 1.578 | +30.2% | 10.609 | 10.692 | -0.8% | 0.85x | 1.93x |
| inkling_global_5doc | PASS | 0.715 | 0.606 | +17.9% | 4.587 | 4.561 | +0.6% | 0.88x | 1.90x |
| inkling_local_1doc | PASS | 0.468 | 0.458 | +2.2% | 1.876 | 1.892 | -0.8% | 1.03x | 1.55x |
| inkling_local_5doc | PASS | 0.510 | 0.502 | +1.6% | 2.554 | 2.535 | +0.8% | 1.13x | 1.83x |
| inkling_small_global_1doc | PASS | 1.159 | 0.915 | +26.7% | 5.911 | 5.925 | -0.2% | 0.73x | 2.08x |
| inkling_small_global_5doc | PASS | 0.567 | 0.452 | +25.4% | 2.502 | 2.485 | +0.7% | 0.90x | 1.51x |
| inkling_small_local_1doc | PASS | 0.323 | 0.311 | +3.9% | 1.140 | 1.112 | +2.5% | 1.11x | 1.34x |
| inkling_small_local_5doc | PASS | 0.363 | 0.350 | +3.8% | 1.427 | 1.425 | +0.1% | 1.21x | 1.51x |

- Forward geomean: 118.688 -> 129.631 TFLOPS (+9.2%)
- Backward geomean: 61.829 -> 61.936 TFLOPS (+0.2%)

## Decision

`ROLLED BACK`

## Attribution

Correct (37 tests, all shapes vs Triton). Inkling global forward +18-30%, band / prefix +9%, window +5%, but causal 4K -7% and 8K -6% (re-measured 3x alternating on one GPU: artifacts/noise_recheck_causal.log). V rows are 256 bytes apart, so the 4 rows of a 16-lane transpose read hit the same 8 banks (the element reads it replaced were conflict-free: lanes read consecutive d).

## Real-training transfer check
- Bucket: K1 (kernel-internal / launch configuration); no cache
- Estimated real-training gain: same as benchmark
- Decision: REJECT (performance)

## Next direction

Round 5: the same transpose reads from a V tile whose 16-byte chunks are XOR-swizzled by row (chunk ^= row & 7), as K is.

## Rollback Analysis
- Change made: V^T A fragments via ds_read_b64_tr_b16 from the unswizzled V tile.
- Expected effect: fewer LDS reads in P . V.
- Actual effect: +5-30% on most shapes, -6/-7% on causal 4K / 8K (>= 5% rule).
- Root cause: bank conflicts: a 16-lane transpose read covers 4 V rows 256 B apart (one 8-bank set).
- Lesson learned: a transpose read needs a swizzled source tile; the element-wise reads it replaces were conflict-free.
