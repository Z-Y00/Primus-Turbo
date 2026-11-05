# Round 1 — BASELINE

## Hypothesis

Baseline round. No optimization change yet; record the starting correctness/performance and choose representative shapes.

## Single change

No code change. Freeze the starting kernel (commit 234b86c1, `flash_fwd.py` / `flash_bwd.py`) and environment state.

## Results

### Validation
- Time: 2026-11-03 20:52
- Validation level: full
- Test command: `pytest -q tests/pytorch/ops/test_flex_attention_flydsl.py tests/pytorch/ops/test_flex_attention_flydsl_paged.py` -> 37 passed
- Benchmark command: `python quick_test_bench.py --shapes all --triton-timing --summary-csv ...`
- Environment: a17-40 GPU 7 (MI300X, gfx942), rocm/primus:v26.8, torch 2.14.0+rocm10.1.0, flydsl 0.3.4.1
- Raw artifacts: `artifacts/full_baseline.log`, `artifacts/benchmark.csv`

| shape | Check | FlyDSL fwd TFLOPS | FlyDSL bwd TFLOPS | FlyDSL fwd ms | FlyDSL bwd ms | Triton fwd ms | Triton bwd ms | fwd time vs Triton | bwd time vs Triton |
|---|---|---|---|---|---|---|---|---|---|
| causal_s4k | PASS | 98.7 | 55.8 | 2.784 | 12.316 | 1.002 | 4.647 | 2.78x | 2.65x |
| causal_s8k | PASS | 119.4 | 59.9 | 4.607 | 22.934 | 1.704 | 8.980 | 2.70x | 2.55x |
| window1k_s8k | PASS | 106.3 | 75.1 | 1.212 | 4.292 | 0.626 | 2.313 | 1.93x | 1.86x |
| band1k_s8k | PASS | 130.3 | 87.0 | 1.976 | 7.398 | 0.957 | 4.966 | 2.07x | 1.49x |
| prefix_lm_s8k | PASS | 122.3 | 61.9 | 4.565 | 22.569 | 1.920 | 9.367 | 2.38x | 2.41x |
| inkling_global_1doc | PASS | 84.5 | 27.4 | 3.253 | 25.115 | 3.200 | 8.074 | 1.02x | 3.11x |
| inkling_global_5doc | PASS | 65.2 | 16.9 | 1.087 | 10.512 | 1.234 | 3.307 | 0.88x | 3.18x |
| inkling_local_1doc | PASS | 46.2 | 27.4 | 0.720 | 3.036 | 0.820 | 1.648 | 0.88x | 1.84x |
| inkling_local_5doc | PASS | 42.6 | 21.1 | 0.681 | 3.437 | 0.793 | 1.574 | 0.86x | 2.18x |
| inkling_small_global_1doc | PASS | 68.2 | 25.8 | 2.017 | 13.320 | 1.985 | 4.510 | 1.02x | 2.95x |
| inkling_small_global_5doc | PASS | 36.2 | 15.1 | 0.980 | 5.873 | 0.907 | 2.488 | 1.08x | 2.36x |
| inkling_small_local_1doc | PASS | 32.4 | 19.0 | 0.514 | 2.186 | 0.502 | 1.481 | 1.02x | 1.48x |
| inkling_small_local_5doc | PASS | 30.0 | 17.7 | 0.483 | 2.045 | 0.498 | 1.118 | 0.97x | 1.83x |

GEOMEAN Forward TFLOPS 66.725, Backward TFLOPS 32.622
Correctness: output and all gradients within 5.1e-3 relative max error of the Triton backend (gate 2e-2).

## Decision

`BASELINE`

## Attribution

- Dense forward is 1.9-2.8x Triton's time, yet the Inkling forward (same head dim 128, plus a bias load per score) is at parity. The dense FlyDSL forward runs at 106-130 TFLOPS against Triton's ~250-320: the fixed 128x64 tile with 4 waves, single-buffered KV staging and V^T read one element at a time leave the MFMA pipe idle, while on Inkling Triton itself is slowed by the per-score bias gather.
- Backward is 1.5-3.2x slower everywhere: separate dQ and dK/dV kernels recompute S and P twice (7 matmuls vs 5), and the dQ kernel stages K and V per 64-key tile with a barrier pair. Worst on Inkling global (3.1-3.2x), where the hook adds a scattered store per score in the dQ kernel.

## Representative shapes (quick validation)

`causal_s8k` (largest dense, fast path), `window1k_s8k` (local fast path), `band1k_s8k` (block-sparse lists + mask_mod), `inkling_global_5doc` (varlen + bias score_mod + score_grad_hook, worst backward ratio), `inkling_small_local_5doc` (smallest, launch-overhead sensitive).

## Real-training transfer check
- Bucket: n/a (baseline)
- Decision: n/a

## Next direction

Profile the dense forward and the dQ / dK-dV kernels (rocprofv3 kernel times + resource usage) to rank the first hypotheses.
