# Round 11 — ACCEPTED: K/V double buffering in LDS (forward, gfx950 16-bit)

## Hypothesis

Each tile ran barrier -> synchronous K/V staging -> barrier -> compute, so a CTA computed nothing while its next tile loaded. gfx950's 160 KB LDS holds two 32 KB K/V stages for each of 2 CTAs per CU: issue tile n+1's loads, compute tile n, store tile n+1 into the other buffer, one barrier.

## Single change

flash_fwd.py (DB = gfx950 16-bit, no block lists): NBUF = 2 K / V LDS stages; load_kv / store_kv split; compute_one_n_block_db; prologue stages the first tile; the last tile re-stages itself into the idle buffer (no branch); rocdl.waves_per_eu = 2 keeps 2 waves / SIMD. Block-sparse, fp8 and gfx942 keep the single-buffer loop.

## Results

- Validation: full (13 shapes) on a17-31's 8 GPUs; each shape's reference and candidate ran on the same GPU
  (`artifacts/validation.log`, gpu map at the end); tests before benchmarks.
- Raw artifacts: `artifacts/benchmark.csv`, `artifacts/round10_reference_same_gpu.csv`

| shape | Check | ref fwd ms | fwd ms | fwd change | ref bwd ms | bwd ms | bwd change | fwd vs Triton | bwd vs Triton |
|---|---|---|---|---|---|---|---|---|---|
| causal_s4k | PASS | 1.006 | 0.998 | +0.8% | 6.950 | 6.933 | +0.2% | 1.60x | 2.30x |
| causal_s8k | PASS | 1.561 | 1.518 | +2.9% | 12.097 | 12.066 | +0.3% | 1.48x | 2.12x |
| window1k_s8k | PASS | 0.489 | 0.483 | +1.1% | 2.278 | 2.276 | +0.1% | 1.36x | 1.67x |
| band1k_s8k | PASS | 0.770 | 0.754 | +2.2% | 3.786 | 3.774 | +0.3% | 1.41x | 1.04x |
| prefix_lm_s8k | PASS | 1.783 | 1.755 | +1.6% | 11.943 | 11.977 | -0.3% | 1.62x | 1.66x |
| inkling_global_1doc | PASS | 1.732 | 1.622 | +6.8% | 10.604 | 10.656 | -0.5% | 0.88x | 1.92x |
| inkling_global_5doc | PASS | 0.656 | 0.630 | +4.1% | 4.483 | 4.571 | -1.9% | 0.91x | 1.89x |
| inkling_local_1doc | PASS | 0.436 | 0.432 | +0.8% | 1.856 | 1.887 | -1.6% | 0.97x | 1.57x |
| inkling_local_5doc | PASS | 0.473 | 0.473 | +0.2% | 2.563 | 2.481 | +3.3% | 1.06x | 1.78x |
| inkling_small_global_1doc | PASS | 0.989 | 0.939 | +5.3% | 5.909 | 5.904 | +0.1% | 0.76x | 2.07x |
| inkling_small_global_5doc | PASS | 0.507 | 0.483 | +5.0% | 2.558 | 2.504 | +2.1% | 0.95x | 1.54x |
| inkling_small_local_1doc | PASS | 0.307 | 0.299 | +2.7% | 1.118 | 1.097 | +1.9% | 1.07x | 1.38x |
| inkling_small_local_5doc | PASS | 0.346 | 0.337 | +2.9% | 1.450 | 1.440 | +0.7% | 1.17x | 1.50x |

- Forward geomean: 134.468 -> 138.208 TFLOPS (+2.8%)
- Backward geomean: 61.817 -> 62.037 TFLOPS (+0.4%)

## Decision

`ACCEPTED`

## Attribution

Forward +0.2% to +6.8% on every shape (geomean +2.8%; Inkling global +4-7%, causal 8K +2.9%). Kernel trace: LDS 65,536 B per CTA, 116 + 132 = 248 registers. The load latency was only partly exposed after round 7 (two CTAs per CU already overlapped it); band (block lists, single buffer) moved within noise.

## Real-training transfer check
- Bucket: K1 (kernel-internal / launch configuration); no cache
- Estimated real-training gain: same as benchmark
- Decision: ACCEPT-as-real

## Next direction

The dense forward (1.36-1.62x Triton) needs a fresh profile of where cycles go (MFMA busy vs waits) before the next structural change; candidates: one barrier per two tiles, larger query tiles per CTA (8 waves), and the backward register footprint.
