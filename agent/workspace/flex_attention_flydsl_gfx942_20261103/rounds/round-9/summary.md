# Round 9 — ACCEPTED: split the GQA group across dK/dV CTAs when the grid is short

## Hypothesis

Profiling the Inkling backward: on inkling_global_1doc the dK/dV kernel took 12.8 of 18.6 ms.
Its grid is one CTA per (64-key block... 128-key tile, KV head, sequence) and loops over all G = 8
query heads inside: 64 x 2 x 1 = 128 CTAs for 304 CUs, at one CTA per CU (384 + 128 registers,
33 KB LDS), so more than half the GPU idles. Splitting the group's query heads over `split` CTAs
(each writing fp32 partial dK / dV, summed on the host in a fixed order: deterministic) fills
the GPU. Expected: Inkling global backward several-fold faster in dK/dV; dense causal helped too.

## Single change

`flash_bwd.py`: `_build_dkdv(split)` built lazily per split; grid y = KV heads x split, CTA y
-> (kv head, split index) handling G / split query heads; with split > 1 the accumulators are
stored as fp32 partials `[split, ...]` and `dk.copy_(partials.sum(0))`. `_dkdv_split` picks the
smallest power-of-two split (dividing G) that gives at least one CTA per CU; grids that already
fill the GPU are not split. Config sweep inside the round: a first threshold (2 CTAs per CU)
made window1k_s8k (512 CTAs, split 2) 6% slower (partials cost more than they add), so the
threshold is 1 CTA per CU (`artifacts/attempt1_threshold2x_cross_gpu.log`).

## Results

### Validation
- Time: 2026-11-04 13:45
- Node: a17-31, all 8 GPUs; each shape's reference (round 5 kernels) and candidate ran back to
  back on the same GPU (`gpu_map` in `artifacts/validation.log`); tests finished before benchmarks.
- Validation level: full (13 shapes)
- Tests: 37 passed; harness correctness vs Triton: all PASS

| shape | Check | round 5 bwd ms | round 9 bwd ms | bwd change | bwd vs Triton | fwd change (same kernel: noise) |
|---|---|---|---|---|---|---|
| causal_s4k | PASS | 8.435 | 8.428 | +0.1% | 1.79x | +1.0% |
| causal_s8k | PASS | 15.102 | 14.089 | +7.2% | 1.58x | -0.3% |
| window1k_s8k | PASS | 3.047 | 3.081 | -1.1% | 1.37x | -1.0% |
| band1k_s8k | PASS | 5.109 | 5.244 | -2.6% | 1.05x | +0.3% |
| prefix_lm_s8k | PASS | 15.193 | 13.953 | +8.9% | 1.49x | +0.4% |
| inkling_global_1doc | PASS | 19.400 | 12.349 | +57.1% | 1.54x | +1.2% |
| inkling_global_5doc | PASS | 8.398 | 5.813 | +44.5% | 1.77x | +2.2% |
| inkling_local_1doc | PASS | 3.087 | 3.186 | -3.1% | 1.95x | +1.7% |
| inkling_local_5doc | PASS | 3.318 | 3.304 | +0.4% | 2.08x | +1.0% |
| inkling_small_global_1doc | PASS | 10.484 | 7.018 | +49.4% | 1.54x | +0.6% |
| inkling_small_global_5doc | PASS | 4.490 | 3.240 | +38.6% | 1.33x | +0.7% |
| inkling_small_local_1doc | PASS | 2.220 | 1.905 | +16.6% | 1.59x | +5.1% |
| inkling_small_local_5doc | PASS | 1.943 | 1.851 | +5.0% | 1.70x | -0.7% |

### Aggregate (full set, same-GPU reference)
- Backward geomean: 40.930 -> 47.156 TFLOPS (+15.2%)
- Forward geomean: 83.443 -> 84.210 TFLOPS (+0.9%, kernel unchanged)

## Decision

`ACCEPTED` — backward +5% to +57% on 8 shapes, no shape regresses >= 5% (worst
inkling_local_1doc -3.1%, band1k_s8k -2.6%, within same-GPU noise of ~2-5%).

## Attribution

Inkling global layers have 1-5 sequences, 2 KV heads and a 128-key dK/dV tile, so their grids
were 128-640 CTAs; splitting fills the GPU (split 4 or 8). Dense causal / prefix (256 CTAs)
split 2. Local layers (window 512) and window / band already filled the GPU and are unchanged;
their backward cost is in the dQ kernel (bias gather + hook store per score).

## Real-training transfer check
- Bucket: K1 (grid decomposition; per-call fp32 partials, no state across calls)
- Cache key (if any): no cache
- Workload: the split depends only on grid size (shape), so it applies the same in training
- Benchmark gain on this round: backward +15.2% (full set)
- Estimated real-training gain: same
- Decision: ACCEPT-as-real

## Next direction

- The 2-CTA/CU threshold gave causal_s8k +24% (split 4) but hurt window (split 2): the right
  split depends on work per CTA, not only the CTA count (causal tiles carry uneven work).
- Inkling local backward (1.95-2.08x Triton) is dQ-bound: per-score bias gather + scattered hook
  store. Next: profile the dQ kernel's per-score cost.
