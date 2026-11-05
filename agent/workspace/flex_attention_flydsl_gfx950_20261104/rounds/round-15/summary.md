# Round 15 — ACCEPTED: dK/dV at 2 waves per SIMD: K/V staged in LDS, shared swizzled LDS offsets, two-per-CU GQA split (gfx950)

## Hypothesis

The gfx950 dK/dV kernel held each lane's K/V B fragments in registers (64 per lane) on top of 128 accumulator registers, so it ran at 1 wave per SIMD (296-360 registers); the occupancy-2 hint alone spilled 704-728 B. Staging the CTA's K/V rows in LDS once (80 KB with the 32-row Q/dO tile, 2 CTAs in 160 KB) frees those registers. A first cut still spilled 164-288 B: ISA showed every ds_read_b128 had its own swizzled address register (~40, reloaded from scratch each block) and all 16 K/V fragments were loaded up front.

## Single change

flash_bwd_gfx950.py (gfx950 only): dK/dV SharedStorage = q, do (TM=32 rows) + k, v (TN=128 rows), staged once per CTA via _load_rows/_store_rows; per-row LSE / D' by lane shuffle instead of LDS arrays; _Ops.frag_offsets: a lane's 8 K-step offsets = (row*dim + 8 ((lane//32) ^ (row&7))) ^ const + const, shared by Q/dO and (+ 32 wave rows) K/V, reads issued at their MFMA; _Ops.tr_offsets / a_from_cols_tr_at precompute the transpose-read offsets per 32-column group; rocdl.waves_per_eu=2 on dQ and dK/dV; dkdv_tile_m 64 -> 32; _dkdv_split fills two CTAs per CU (up to four with MIN_SPLIT_WORK = 8192 query rows). dq_tile_n stays 64 (32 was -7% on window1k).

## Results

- Validation: full (13 shapes) on cv350-tnndh2-b05-2's 8 MI355 GPUs; each shape's reference and candidate ran on the same GPU
  (`artifacts/validation.log`, gpu map at the end); tests before benchmarks.
- Raw artifacts: `artifacts/benchmark.csv`, `artifacts/previous_reference_same_gpu.csv`

| shape | Check | ref fwd ms | fwd ms | fwd change | ref bwd ms | bwd ms | bwd change | fwd vs Triton | bwd vs Triton |
|---|---|---|---|---|---|---|---|---|---|
| causal_s4k | PASS | 0.999 | 0.995 | +0.4% | 3.978 | 3.188 | +24.8% | 1.66x | 1.05x |
| causal_s8k | PASS | 1.554 | 1.528 | +1.7% | 7.266 | 5.527 | +31.5% | 1.52x | 0.97x |
| window1k_s8k | PASS | 0.497 | 0.494 | +0.5% | 1.427 | 1.272 | +12.1% | 1.57x | 0.93x |
| band1k_s8k | PASS | 0.762 | 0.761 | +0.2% | 2.272 | 1.907 | +19.2% | 1.42x | 0.53x |
| prefix_lm_s8k | PASS | 1.750 | 1.767 | -1.0% | 6.944 | 5.417 | +28.2% | 1.66x | 0.76x |
| inkling_global_1doc | PASS | 1.617 | 1.626 | -0.6% | 7.056 | 5.671 | +24.4% | 0.88x | 1.02x |
| inkling_global_5doc | PASS | 0.713 | 0.632 | +12.9% | 3.594 | 2.735 | +31.4% | 0.93x | 1.13x |
| inkling_local_1doc | PASS | 0.439 | 0.435 | +0.9% | 1.972 | 1.760 | +12.0% | 0.98x | 1.44x |
| inkling_local_5doc | PASS | 0.478 | 0.474 | +0.8% | 2.117 | 1.791 | +18.2% | 1.07x | 1.29x |
| inkling_small_global_1doc | PASS | 0.941 | 0.934 | +0.7% | 3.735 | 2.959 | +26.2% | 0.76x | 1.04x |
| inkling_small_global_5doc | PASS | 0.493 | 0.482 | +2.3% | 2.023 | 1.605 | +26.1% | 0.97x | 0.97x |
| inkling_small_local_1doc | PASS | 0.306 | 0.314 | -2.6% | 1.087 | 0.966 | +12.6% | 1.13x | 1.20x |
| inkling_small_local_5doc | PASS | 0.340 | 0.339 | +0.3% | 1.377 | 1.182 | +16.4% | 1.18x | 1.23x |

- Forward geomean: 135.432 -> 137.075 TFLOPS (+1.2%)
- Backward geomean: 84.872 -> 103.194 TFLOPS (+21.6%)

## Decision

`ACCEPTED`

## Attribution

dK/dV ISA: 256 registers, 0 scratch (was 288 B / 236 spilled dwords in the first cut); loop = 32 MFMA, 64 LDS reads, 2 barriers per 32-row block. window1k was -5% until the split filled 2 CTAs per CU (256 CTAs on 256 CUs ran 1 wave per SIMD). Every shape faster: +12% (window1k, inkling_local_1doc) to +31.5% (causal_s8k, inkling_global_5doc); tests 37/37. Variants measured on the way (same gate): dq_tile_n 32 -> window1k -7.2%; split rule unchanged -> window1k -4.7/-5.1/-5.9% (3 reruns).

## Real-training transfer check
- Bucket: K1 (kernel-internal / launch configuration); no cache
- Estimated real-training gain: same as benchmark
- Decision: ACCEPT-as-real

## Next direction

MI355 backward: overlap the next Q/dO tile's global loads with the current block (exposed load latency at TM=32; registers are at 256 so via LDS DMA, buffer_load ... lds); dQ kernel at 2 waves per SIMD with the same offset sharing. MI300 backward: evolve flash_bwd_gfx942.py separately (64 KB LDS: K/V in LDS does not fit 2 CTAs).
