# flex_attention FLYDSL Optimization Log

## Basic Information
- Target operator: flex_attention (forward + backward)
- Implementation language: FlyDSL
- Backend: FLYDSL (reference: TRITON backend, same harness)
- Target GPU: gfx942 (MI300X, a17-40 GPU 7)
- Campaign: agent/workspace/flex_attention_flydsl_gfx942_20261103
- Start time: 2026-11-03 20:31
- Accept rule: forward and backward tracked separately (user choice): accept when one aggregate improves and neither regresses; no shape may regress >= 5% in either direction.
- Current status: Optimizing (round-1 done)

## Baseline
- Time: 2026-11-03 20:52
- Commit: 234b86c1
- Validation level: full (13 shapes), all Check PASS; tests 37 passed
- Forward aggregate (geomean TFLOPS): 66.725
- Backward aggregate (geomean TFLOPS): 32.622
- Detailed data: rounds/round-1/summary.md
- Quick baseline log: rounds/round-1/artifacts/quick_baseline.log

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
## Optimization History

### round-2 — stage V transposed in LDS (forward)
- Time: 2026-11-03 20:57
- Validation level: quick
- Hypothesis: P . V reads V^T one element at a time; transposed staging lets it read 4 keys per ds_read_b64.
- Changes: flash_fwd.py V LDS layout [DV, TN+4], transposed staging, 64-bit V^T fragment copy (bf16/fp16).
- Result: forward geomean 79.80 -> 65.84 TFLOPS (-17.5%), backward unchanged ❌
- Test: PASS (harness vs Triton)
- Decision: rollback
- Detailed data: rounds/round-2/summary.md
- Notes: registers 200 -> 264 (occupancy 2 -> 1 wave/SIMD); LDS bank conflicts (1.02 G cycles) unchanged — they come from the K A-fragment reads (32-way: K rows 64 dwords apart).

### round-3 — pad K LDS rows by 16 bytes (forward)
- Time: 2026-11-03 21:13
- Validation level: quick
- Hypothesis: K A-fragment reads are 32-way bank conflicted; padding rows spreads them.
- Changes: flash_fwd.py K LDS stride D + PACK.
- Result: forward geomean 79.80 -> 80.65 TFLOPS (+1.1%); dense +7-15%, Inkling -11..-13% ❌
- Test: PASS (harness vs Triton)
- Decision: rollback
- Detailed data: rounds/round-3/summary.md
- Notes: bank conflicts 1022 M -> 68 M cycles, but LDS 32 KB -> 33 KB per CTA halves CTAs/CU. Next: XOR swizzle (zero bytes).

### round-4 — XOR-swizzle the K LDS tile (forward)
- Time: 2026-11-03 21:36
- Validation level: quick
- Hypothesis: remove the K-read bank conflicts without adding LDS bytes.
- Changes: flash_fwd.py K LDS view composed with Swizzle<3, log2 PACK, log2 D - log2 PACK>; staging store XORs the chunk index with row & 7.
- Result: forward geomean 79.80 -> 101.22 TFLOPS (+26.8%), backward unchanged ✅
- Test: PASS (37 tests; harness vs Triton)
- Decision: accept
- Detailed data: rounds/round-4/summary.md
- Notes: conflicts 1022 M -> 68 M cycles; LDS 32 KB, 232 registers. causal_s8k forward 4.62 -> 2.97 ms (Triton 1.70).

## Current Best (round 4, quick set)
| shape | baseline fwd ms | current fwd ms | baseline bwd ms | current bwd ms |
|---|---|---|---|---|
| causal_s8k | 4.607 | 2.972 | 22.934 | 23.047 |
| window1k_s8k | 1.212 | 0.949 | 4.292 | 4.203 |
| band1k_s8k | 1.976 | 1.402 | 7.398 | 7.361 |
| inkling_global_5doc | 1.087 | 0.976 | 10.512 | 10.594 |
| inkling_small_local_5doc | 0.483 | 0.458 | 2.045 | 2.212 |

### round-5 — XOR-swizzle the backward's LDS tiles
- Time: 2026-11-03 21:59
- Validation level: quick
- Hypothesis: the backward's staged tiles have the forward's 32-way A-fragment bank conflict.
- Changes: flash_bwd.py `_lds_view` (swizzle-composed row and column views), `_stage_rows` swizzled stores.
- Result: backward geomean 40.55 -> 54.03 TFLOPS (+33.2%), forward unchanged ✅
- Test: PASS (37 tests; harness vs Triton)
- Decision: accept
- Detailed data: rounds/round-5/summary.md
- Notes: causal 8K backward 23.05 -> 15.20 ms (Triton 8.98). dK/dV is 10 of the 15 ms, one wave per SIMD.

### round-6 — transposed V in LDS with an XOR swizzle (forward)
- Time: 2026-11-04 10:52
- Validation level: quick
- Hypothesis: Round 2 lost to LDS > 32 KB; a swizzled V^T keeps 32 KB and cuts LDS reads.
- Changes: flash_fwd.py V^T staging + Swizzle<3,3,3> view + 64-bit fragment copy.
- Result: forward geomean 101.48 -> 82.35 TFLOPS (-18.9%) ❌
- Test: PASS (37 tests; harness vs Triton)
- Decision: rollback
- Detailed data: rounds/round-6/summary.md
- Notes: LDS insts -42% but registers 232 -> 288 (occupancy 2 -> 1). Next: test a waves_per_eu = 2 cap alone.

### round-7 — waves_per_eu = 2 on the forward kernel
- Time: 2026-11-04 11:05
- Validation level: quick
- Hypothesis: neutral alone; measures the cap before retrying transposed V under it.
- Changes: flash_fwd.py value_attrs rocdl.waves_per_eu = 2, flat_work_group_size 256,256.
- Result: forward geomean 101.48 -> 100.63 TFLOPS (-0.8%, noise) ➖
- Test: PASS (harness vs Triton)
- Decision: rollback (neutral)
- Detailed data: rounds/round-7/summary.md

### round-8 — transposed, swizzled V under waves_per_eu = 2 (forward)
- Time: 2026-11-04 13:10
- Validation level: quick (a17-31; a17-40 went offline, Round 5 re-measured on a17-31 as reference)
- Hypothesis: Round 6's LDS saving pays once registers are capped at 256.
- Changes: Round 6 V^T staging + Round 7 waves_per_eu hint.
- Result: forward geomean 100.61 -> 97.60 TFLOPS (-3.0%); Inkling -5.2 / -5.8% ❌
- Test: PASS (37 tests; harness vs Triton)
- Decision: rollback
- Detailed data: rounds/round-8/summary.md
- Notes: 3 consecutive rollbacks -> escalate to ISA-level inspection before the next forward change.

### note 2026-11-04 13:10 — faster validation, full re-measure of the round-5 lineage
- a17-40 went offline; rounds now run on a17-31 (same MI300X model). Round 5's kernels were
  re-measured there (`profiles/full_round5_a17-31_with_triton.csv`, all 13 shapes, with Triton):
  this is the reference for later rounds on a17-31.
- Validation now spreads over the node's 8 GPUs (`par_run.py` + `integration/run_par.sh`):
  pytest sharded by test id, one benchmark process per shape per GPU, each with its own HOME /
  JIT caches. Tests (37) + all 13 shapes with Triton timing: 256 s wall (was ~19 min on one GPU).
  The per-round accept data keeps the same CSV schema (merged `benchmark.csv`).

### round-9 — split the GQA group across dK/dV CTAs when the grid is short
- Time: 2026-11-04 13:45
- Validation level: full (13 shapes), reference = round 5 kernels on the same GPU per shape
- Hypothesis: Inkling global dK/dV grids (128 CTAs for 304 CUs) leave the GPU idle.
- Changes: flash_bwd.py per-split dK/dV launchers, fp32 partials summed on the host; split chosen to give >= 1 CTA per CU.
- Result: backward geomean 40.93 -> 47.16 TFLOPS (+15.2%); inkling_global_1doc 19.40 -> 12.35 ms ✅
- Test: PASS (37 tests; harness vs Triton)
- Decision: accept
- Detailed data: rounds/round-9/summary.md
- Notes: runner now compares every kernel of a shape on the same GPU (user request); tests finish before benchmarks.

### round-10 — work-aware dK/dV split heuristic
- Validation level: full (13 shapes), same-GPU reference
- Hypothesis: Round 9 splits the GQA group only until each CU has one dK/dV CTA; its first attempt showed causal 8K gains +24% at split 4 vs +7% at split 2, while window lost at more splits. The right split depends on work per CTA: keep splitting up to 2 CTAs/CU while each CTA keeps >= 128 (query tile x head) iterations (estimated from the mask: causal ~ half the query tiles, window ~ (window + key tile) / query tile, else all).
- Changes: flash_bwd.py `_dkdv_split(ctas, seqlen_q, window_left, window_right)` with MIN_SPLIT_WORK = 128; causal / prefix 8K now split 4 (was 2), other shapes keep their split.
- Result: forward 83.38 -> 83.91 TFLOPS (+0.6%), backward 47.20 -> 48.59 TFLOPS (+3.0%) ✅
- Decision: ACCEPTED
- Detailed data: rounds/round-10/summary.md

### round-11 — rel-bias mods index from SeqlenInfo (no per-score cu_seqlens loads)
- Validation level: full (13 shapes), same-GPU reference
- Hypothesis: The Inkling rel-bias FlyDSL mods reload cu_seqlens[b] and cu_seqlens[b+1] for every score (Triton loads them once per tile, b being scalar there); the dQ kernel does it twice per score (score_mod + hook), with the hook's stores preventing reuse. SeqlenInfo already holds the sequence's offset and length (from the same cu_seqlens, once per CTA). Expected: Inkling fwd / bwd faster, most on the dQ-bound local layers; dense unchanged.
- Changes: mods.py make_rel_bias_mods: rel_index(q_idx, kv_idx, seqlen_info) uses seqlen_info.offset_q / seqlen_q; removes 2 buffer loads per score in score_mod and in the hook. (First attempt's reference tree accidentally had the new mods.py; rerun with the committed files as reference, kept in rounds/round-11/ref/.)
- Result: forward 82.16 -> 84.43 TFLOPS (+2.8%), backward 48.46 -> 51.06 TFLOPS (+5.4%) ✅
- Decision: ACCEPTED
- Detailed data: rounds/round-11/summary.md

### round-12 — unmasked interior KV tiles in the forward
- Validation level: full (13 shapes), same-GPU reference
- Hypothesis: ISA of the forward's KV-tile loop (causal_s8k, round-11 kernels, profiles/fwd_round11_isa.s): per 64-key tile 64 MFMA vs 816 VALU, 135 SALU, 103 s_waitcnt, 158 ds_read: the loop is VALU-bound (~3.3k VALU cycles vs ~2k MFMA cycles). Much of the VALU is the per-score mask (positions, causal / window / seqlen compares, selects, masked softmax). Tiles whose keys are all kept for every query of the block need none of it; Triton / FA4 split their loops the same way. Expected: causal / window / Inkling forward faster; block-list masks (band, prefix) unchanged.
- Changes: block_info.py `get_n_block_interior` (blocks wholly kept by causal / local and before the sequence end); flash_fwd.py runs masked [n_min, n_lo), unmasked [n_lo, n_hi), masked [n_hi, n_max) when there is no mask_mod; softmax.py online_softmax(keep=None) skips the selects.
- Result: forward 84.03 -> 86.61 TFLOPS (+3.1%), backward 51.10 -> 50.91 TFLOPS (-0.4%) ✅
- Decision: ACCEPTED
- Detailed data: rounds/round-12/summary.md

### round-13 — row max via v_max_f32 (fx.maxnumf)
- Validation level: full (13 shapes), same-GPU reference
- Hypothesis: After round 12 the forward's unmasked KV-tile loop still has 661 VALU per tile; the row max is a compare + select per element (66 v_cmp_gt_f32 + ~130 v_cndmask). fx.maxnumf lowers to one v_max_f32. Expected: ~100 fewer VALU per tile, faster forward on every shape.
- Changes: softmax.py _max -> fx.maxnumf.
- Result: forward 86.14 -> 86.51 TFLOPS (+0.4%), backward 50.46 -> 50.74 TFLOPS (+0.6%) ❌
- Decision: ROLLED BACK
- Detailed data: rounds/round-13/summary.md

### round-14 — pairwise row reductions in the online softmax
- Validation level: full (13 shapes), same-GPU reference
- Hypothesis: Round 13 suggested the 32-deep serial dependency chains of the per-tile row max and row sum (acc = op(acc, v)) limit the forward more than their instruction count. A pairwise tree cuts each chain to 5. Expected: faster forward on every shape.
- Changes: softmax.py _row_reduce: pairwise tree instead of a serial fold (compare + select max kept).
- Result: forward 86.05 -> 86.78 TFLOPS (+0.8%), backward 51.14 -> 51.12 TFLOPS (-0.0%) ❌
- Decision: ROLLED BACK
- Detailed data: rounds/round-14/summary.md

## Directions to Try (2026-11-04 15:05, after round 14; campaign paused to move to MI355)
- [ ] Forward K/V software prefetch (load tile n+1 during tile n; register budget 232/256, waves_per_eu cap as fallback)
- [ ] Forward P f32 -> bf16 cast without the NaN check (RNE via bfe + add3 + perm), exp2 without denormal fix-ups
- [ ] Interior (unmasked) tiles for block-list full blocks (band, prefix-LM)
- [ ] dK/dV footprint: 512 registers, LDS 512 B over 32 KB (one CTA / CU)
- [ ] Inkling local dQ: per-score bias gather + hook scattered store
- [ ] 5-matmul fused backward, deterministic
- [x] ~~transposed V in LDS~~ (rounds 2, 6, 8), ~~v_max_f32 row max~~ (13), ~~tree reductions~~ (14)

### round-15 (re-measure, no code change) — shared changes from the gfx950 campaign, on MI300X
- Time: 2026-11-04 19:50; node a17-40 (a17-31 fully busy); reference = commit eb2a77f9 (gfx942 round 12) on the same GPU per shape
- Shared changes measured: gfx950 round 7 (K/V staging loads issued before the LDS stores) and round 10 (a key step's
  P . V fragment reads before its MFMAs); the gfx950-only paths (32x32x16, transpose reads, double buffering) are off on gfx942.
- Result: forward geomean 86.43 -> 92.24 TFLOPS (+6.7%): band +26%, Inkling small global +10-16%, causal 8K +10%, prefix +8%,
  window +6%; no shape slower than -1.4%. Backward unchanged (kernel untouched). Tests 37 passed.
- Detailed data: rounds/round-15/artifacts/

### round-16 — issue all of a backward stage's global loads before its LDS stores (dQ, dK/dV)
- Validation level: full (13 shapes), same-GPU reference
- Hypothesis: The backward's _stage_rows staged each 16-byte pack as load -> wait -> LDS store, the serialization the forward lost in gfx950 round 7; dQ stages K and V, dK/dV stages Q and dO, for every block they visit. Loading both tiles before any store pays one load latency per stage.
- Changes: flash_bwd.py: _stage_rows split into _load_rows / _store_rows; both kernels load both staged tiles, then store. Shared code (gfx942 and gfx950).
- Result: forward 90.97 -> 91.43 TFLOPS (+0.5%), backward 50.56 -> 55.29 TFLOPS (+9.3%) ✅
- Decision: ACCEPTED
- Detailed data: rounds/round-16/summary.md

### round-17 — refactor (no performance change): separate gfx942 and gfx950 backward kernels
- 2026-11-05 00:15. flash_bwd.py is now a dispatcher; flash_bwd_gfx942.py (32x32x8, element-wise column reads) and
  flash_bwd_gfx950.py (32x32x16, transpose reads, asserts gfx950) evolve separately from here (user request).
- Validation (same-GPU reference = previous commit): all 13 shapes within noise on both GPUs; tests 37 passed on both.
- Occupancy-2 probes before the split (gfx950, uncommitted): waves_per_eu=2 alone spills 704-728 B; + 32-row tiles
  172-268 B (dQ clean at 216 regs); + per-block K/V fragment reload 124-132 B but slower; + S->dV / dP->dK reorder
  316-328 B. gfx942: 288-1080 B in every variant. The spills are the loop-invariant K/V fragments reloaded from
  scratch each block. Chosen next (user): gfx950 dK/dV stages K and V in LDS (80 KB per CTA, 2 CTAs in 160 KB).
