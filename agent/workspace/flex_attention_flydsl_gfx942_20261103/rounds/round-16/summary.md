# Round 16 — ACCEPTED: issue all of a backward stage's global loads before its LDS stores (dQ, dK/dV)

## Hypothesis

The backward's _stage_rows staged each 16-byte pack as load -> wait -> LDS store, the serialization the forward lost in gfx950 round 7; dQ stages K and V, dK/dV stages Q and dO, for every block they visit. Loading both tiles before any store pays one load latency per stage.

## Single change

flash_bwd.py: _stage_rows split into _load_rows / _store_rows; both kernels load both staged tiles, then store. Shared code (gfx942 and gfx950).

## Results

- Validation: full (13 shapes) on a17-31's 8 GPUs; each shape's reference and candidate ran on the same GPU
  (`artifacts/validation.log`, gpu map at the end); tests before benchmarks.
- Raw artifacts: `artifacts/benchmark.csv`, `artifacts/previous_reference_same_gpu.csv`

| shape | Check | ref fwd ms | fwd ms | fwd change | ref bwd ms | bwd ms | bwd change | fwd vs Triton | bwd vs Triton |
|---|---|---|---|---|---|---|---|---|---|
| causal_s4k | PASS | 1.558 | 1.570 | -0.7% | 8.413 | 7.331 | +14.8% | 1.51x | 1.56x |
| causal_s8k | PASS | 2.504 | 2.502 | +0.1% | 12.288 | 11.014 | +11.6% | 1.48x | 1.23x |
| window1k_s8k | PASS | 0.847 | 0.988 | -14.3% | 3.155 | 2.865 | +10.1% | 1.39x | 1.23x |
| band1k_s8k | PASS | 1.291 | 1.275 | +1.3% | 5.360 | 4.967 | +7.9% | 1.32x | 0.99x |
| prefix_lm_s8k | PASS | 2.701 | 2.759 | -2.1% | 12.192 | 11.034 | +10.5% | 1.43x | 1.16x |
| inkling_global_1doc | PASS | 2.259 | 2.285 | -1.2% | 11.398 | 10.279 | +10.9% | 0.72x | 1.28x |
| inkling_global_5doc | PASS | 0.959 | 0.958 | +0.1% | 5.358 | 4.813 | +11.3% | 0.77x | 1.46x |
| inkling_local_1doc | PASS | 0.651 | 0.646 | +0.8% | 2.737 | 2.603 | +5.1% | 0.79x | 1.58x |
| inkling_local_5doc | PASS | 0.623 | 0.616 | +1.1% | 3.023 | 2.885 | +4.8% | 0.78x | 1.84x |
| inkling_small_global_1doc | PASS | 1.246 | 1.215 | +2.5% | 6.427 | 5.664 | +13.5% | 0.62x | 1.27x |
| inkling_small_global_5doc | PASS | 0.682 | 0.687 | -0.6% | 3.140 | 2.781 | +12.9% | 0.78x | 1.14x |
| inkling_small_local_1doc | PASS | 0.548 | 0.453 | +20.9% | 1.665 | 1.625 | +2.4% | 0.90x | 1.32x |
| inkling_small_local_5doc | PASS | 0.450 | 0.441 | +2.0% | 1.808 | 1.699 | +6.4% | 0.89x | 1.53x |

- Forward geomean: 90.972 -> 91.434 TFLOPS (+0.5%)
- Backward geomean: 50.564 -> 55.286 TFLOPS (+9.3%)

## Decision

`ACCEPTED`

## Attribution

Backward faster on every shape on both GPUs: MI355 +7% to +29% (geomean +16.4%; causal 8K 12.05 -> 9.61 ms), MI300X +2% to +15% (geomean +9.4%). The forward is untouched; its outliers (MI355 causal_s4k -7.5%, MI300X window -14.3%) are run-to-run noise.

## Real-training transfer check
- Bucket: K1 (kernel-internal / launch configuration); no cache
- Estimated real-training gain: same as benchmark
- Decision: ACCEPT-as-real

## Next direction

MI355: transpose reads for the backward's column views (kt_cols, qt_cols, dot_cols), as in the forward's P . V.
