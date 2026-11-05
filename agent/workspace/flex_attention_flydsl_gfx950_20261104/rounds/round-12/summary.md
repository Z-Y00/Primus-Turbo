# Round 12 — ACCEPTED: issue all of a backward stage's global loads before its LDS stores (dQ, dK/dV)

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
| causal_s4k | PASS | 1.002 | 1.083 | -7.5% | 6.981 | 5.433 | +28.5% | 1.76x | 1.78x |
| causal_s8k | PASS | 1.524 | 1.520 | +0.3% | 12.045 | 9.610 | +25.3% | 1.52x | 1.70x |
| window1k_s8k | PASS | 0.498 | 0.489 | +1.8% | 2.267 | 1.892 | +19.8% | 1.61x | 1.38x |
| band1k_s8k | PASS | 0.767 | 0.769 | -0.3% | 3.784 | 3.059 | +23.7% | 1.43x | 0.87x |
| prefix_lm_s8k | PASS | 1.787 | 1.757 | +1.7% | 11.907 | 9.666 | +23.2% | 1.63x | 1.34x |
| inkling_global_1doc | PASS | 1.614 | 1.613 | +0.0% | 10.594 | 8.975 | +18.0% | 0.87x | 1.63x |
| inkling_global_5doc | PASS | 0.633 | 0.633 | -0.1% | 4.556 | 4.059 | +12.2% | 0.93x | 1.68x |
| inkling_local_1doc | PASS | 0.439 | 0.434 | +1.1% | 1.957 | 1.791 | +9.3% | 0.98x | 1.48x |
| inkling_local_5doc | PASS | 0.480 | 0.473 | +1.5% | 2.558 | 2.335 | +9.6% | 1.07x | 1.71x |
| inkling_small_global_1doc | PASS | 0.941 | 0.935 | +0.7% | 5.875 | 4.974 | +18.1% | 0.76x | 1.75x |
| inkling_small_global_5doc | PASS | 0.490 | 0.493 | -0.6% | 2.517 | 2.227 | +13.0% | 0.98x | 1.35x |
| inkling_small_local_1doc | PASS | 0.305 | 0.300 | +1.6% | 1.123 | 1.048 | +7.2% | 1.07x | 1.27x |
| inkling_small_local_5doc | PASS | 0.346 | 0.339 | +2.2% | 1.434 | 1.329 | +7.9% | 1.16x | 1.39x |

- Forward geomean: 136.438 -> 136.650 TFLOPS (+0.2%)
- Backward geomean: 61.678 -> 71.793 TFLOPS (+16.4%)

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
