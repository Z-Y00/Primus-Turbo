# flex_attention FLYDSL Optimization Log (gfx950)

## Basic Information
- Target: FlyDSL flex attention forward + backward on MI355X (gfx950), vs the Triton backend
- Campaign: agent/workspace/flex_attention_flydsl_gfx950_20261104 (continues the gfx942 campaign's lineage: kernels at commit 2350bba4, gfx942 rounds 4-12 accepted)
- Accept rule: as on gfx942: forward and backward tracked separately, no shape may regress >= 5%; every comparison on one GPU per shape
- Node: cv350-tnndh2-b05-2, 8 GPUs; harness `par_run.py` (tests sharded, then one job per shape)

## Baseline (round 1, 2026-11-04 16:20)
- Tests: 37 passed; all 13 shapes PASS against Triton
- FlyDSL time vs Triton: dense forward 1.88-2.56x, Inkling forward 0.92-1.31x; dense backward 1.22-2.69x, Inkling backward 1.41-2.21x
- Detailed data: rounds/round-1/artifacts/benchmark.csv
- Note: the kernels are tuned for gfx942: 32x32x8 bf16 MFMA (gfx950 has 32x32x16, twice the K per instruction), a 64 KB-per-CU LDS budget (gfx950 has 160 KB), and V^T read element-wise (gfx950 has ds_read_b64_tr_b16 transpose reads).

## Optimization History

### round-2 — 32x32x16 MFMA in the forward for 16-bit inputs on gfx950
- Validation level: full (13 shapes), same-GPU reference
- Hypothesis: gfx950 has a 32x32x16 bf16/fp16 MFMA, twice the reduction depth per instruction of gfx942's 32x32x8 that the forward uses. The forward's fp8 path already runs a 16-deep step (8-element fragments; V rows permuted so the accumulator layout feeds the P . V B operand). Expected: fewer MFMA issues and fragment loads per tile, faster forward on every shape.
- Changes: flash_fwd.py: `mfma_k` (16 for fp8 and, by default, for bf16 / fp16 on gfx950; 8 otherwise): KS = mfma_k, Q / K fragment copies 128-bit when 8 x 16-bit, V rows permuted whenever KS = 16. gfx942 keeps 32x32x8 (unchanged code path).
- Result: forward 104.85 -> 119.25 TFLOPS (+13.7%), backward 56.12 -> 56.38 TFLOPS (+0.5%) ✅
- Decision: ACCEPTED
- Detailed data: rounds/round-2/summary.md

### round-3 — 32x32x16 MFMA in the backward (dQ, dK/dV) on gfx950
- Validation level: full (13 shapes), same-GPU reference
- Hypothesis: Round 2's MFMA change applied to the backward. The backward feeds accumulators straight into the next MFMA's K in three places (dQ = dS . K over keys; dK, dV over queries), so the 16-deep step needs the accumulator-row order on those operands. K, Q and dO are also used as row operands, so instead of permuting rows at staging, only the transposed (column) views get the bit-2/3 swap as a layout.
- Changes: flash_bwd.py: `mfma_k` (16 on gfx950, 8 otherwise); _Ops builds the MFMA and its fragment copies from it (128-bit when 8 x 16-bit); `_k16_perm` gives kt_cols / qt_cols / dot_cols a (4,2,2,n/16):(1,8,4,16) reduction mode under the chunk swizzle; accumulator -> B fragments take KS/2 values. gfx942 unchanged.
- Result: forward 118.37 -> 119.44 TFLOPS (+0.9%), backward 56.14 -> 62.04 TFLOPS (+10.5%) ✅
- Decision: ACCEPTED
- Detailed data: rounds/round-3/summary.md

## Profile after round 3 (2026-11-04 17:05, MI355X)
- Forward causal_s8k: ~1.68 ms (Triton 1.02); 84 + 132 = 216 registers (2 waves/SIMD), LDS 32 KB; per 64-key tile the
  unmasked loop has 32 MFMA (32x32x16) vs 510 VALU, the masked loop 702 VALU. With MFMA twice as fast as gfx942's, the
  forward is now clearly VALU-bound. Unmasked-tile VALU: v_add 66, v_perm 64, v_pk_mul 59, v_cndmask ~100, v_cmp ~66,
  v_exp 33 + v_ldexp 33 (exp2 range fix-ups), v_cvt_pk_bf16_f32 16 (gfx950 has the packed bf16 cast natively).
  The per-score minimum is ~1 FMA + 1 exp + 1 max + 1 add + 1/2 cvt, plus 1/2 pk_mul per O element: ~180 VALU per tile.
- Backward causal_s8k: dQ ~4.0 ms (128 + 208 = 336 registers, 1 wave/SIMD), dK/dV ~7.8 ms (128 + 336 = 464 registers,
  LDS 33,280 B). gfx950's 160 KB LDS no longer limits occupancy; registers do.
- Inkling forward is at or near Triton; Inkling backward 1.4-2.1x.

## Directions to Try (gfx950)
- [ ] Forward exp2 without the range fix-ups (raw v_exp_f32; arguments are <= 0 after the max subtraction)
- [ ] Forward: fold softmax_scale * log2(e) into one multiply / FMA with the max subtraction (no score_mod case)
- [ ] Row max without compare + select (IEEE-mode canonicalization made v_max_f32 cost extra on gfx942)
- [ ] V^T via ds_read_b64_tr_b16 (gfx950 transpose read) instead of element-wise reads
- [ ] Backward register footprint (dQ 336, dK/dV 464): one wave per SIMD

### round-4 — V^T via ds_read_b64_tr_b16 (unswizzled V)
- Validation level: full (13 shapes), same-GPU reference
- Hypothesis: With 16-deep MFMA the forward's P . V A fragment is 8 V^T elements, read one 16-bit element at a time. gfx950's LDS transpose read (ds_read_b64_tr_b16) fetches a 4 x 16 block per 16 lanes and returns it transposed; two of them build the fragment straight from the row-major (row-permuted) V tile. Expected: fewer LDS instructions, faster forward.
- Changes: flash_fwd.py: VTR (gfx950 16-bit, KS 16): P . V A fragments from two LDSReadTrans16_64b copies (lane address: key + (lane % 16) // 4 + 8 * (lane // 32), d + 16 * ((lane % 32) // 16) + 4 * (lane % 4)); V tile unchanged.
- Result: forward 118.69 -> 129.63 TFLOPS (+9.2%), backward 61.83 -> 61.94 TFLOPS (+0.2%) ❌
- Decision: ROLLED BACK
- Detailed data: rounds/round-4/summary.md

### round-5 — transpose reads from a row-XOR-swizzled V tile
- Validation level: full (13 shapes), same-GPU reference
- Hypothesis: Round 4's transpose reads regressed causal by 6-7%, attributed to bank conflicts: a 16-lane read covers 4 V rows 256 B apart. XOR-swizzling V's 16-byte chunks by row (chunk ^= row & 7), as K is, should spread them.
- Changes: flash_fwd.py: with VTR, V staging stores chunk (row, c) at c ^ (row & 7); the transpose-read addresses apply the same XOR.
- Result: forward 118.69 -> 122.67 TFLOPS (+3.4%), backward 61.80 -> 62.18 TFLOPS (+0.6%) ❌
- Decision: ROLLED BACK
- Detailed data: rounds/round-5/summary.md

### round-6 — transpose reads from a V tile swizzled by (row & 3) << 1
- Validation level: full (13 shapes), same-GPU reference
- Hypothesis: Round 5's swizzle left the transpose-read conflicts untouched (rows 0/1 and 2/3 shared a 32-byte span). chunk ^= (row & 3) << 1 puts the 4 rows a 16-lane transpose read covers on 4 different chunk pairs.
- Changes: flash_fwd.py: round 4's transpose reads; V staging stores and transpose-read addresses XOR the chunk with (row & 3) * 2.
- Result: forward 117.96 -> 126.84 TFLOPS (+7.5%), backward 62.07 -> 61.89 TFLOPS (-0.3%) ❌
- Decision: ROLLED BACK
- Detailed data: rounds/round-6/summary.md

### round-7 — issue all K/V staging loads before the LDS stores (forward)
- Validation level: full (13 shapes), same-GPU reference
- Hypothesis: Round 6's ISA: the forward's K/V staging is 8 x (buffer_load; s_waitcnt vmcnt(0); ds_write), each global load waited before the next is issued, so every tile pays 8 serial load latencies. Issuing all loads first, then storing, pays one.
- Changes: flash_fwd.py stage_kv: loads into register packs first (K then V), LDS stores after; the V row permutation and K swizzle unchanged. Shared code: gfx942 gets it too.
- Result: forward 117.58 -> 123.54 TFLOPS (+5.1%), backward 61.96 -> 61.91 TFLOPS (-0.1%) ✅
- Decision: ACCEPTED
- Detailed data: rounds/round-7/summary.md

### round-8 — V^T via ds_read_b64_tr_b16 from a (row & 3) << 1 swizzled V tile, on batched staging
- Validation level: full (13 shapes), same-GPU reference
- Hypothesis: Round 6's transpose reads (63% fewer LDS instructions) lost on causal because the loop was serialized; round 7 removed the staging serialization. Re-applied on top, the read savings should now show on every shape.
- Changes: flash_fwd.py (gfx950 16-bit): P . V A fragments from two LDSReadTrans16_64b reads; V staging stores and the reads XOR the 16-byte chunk with (row & 3) * 2 (round 6's corrected swizzle). gfx942 / fp8 unchanged (element reads, unswizzled V).
- Result: forward 122.90 -> 135.10 TFLOPS (+9.9%), backward 61.86 -> 61.90 TFLOPS (+0.1%) ✅
- Decision: ACCEPTED
- Detailed data: rounds/round-8/summary.md

### round-9 — bare v_exp_f32 (rocdl.exp2) in the online softmax
- Validation level: full (13 shapes), same-GPU reference
- Hypothesis: The forward's KV-tile loop runs far more VALU than the online softmax needs; exp2 lowers with range fix-ups (v_ldexp + compares + selects) although every argument is <= 0. rocdl.exp2 is the bare v_exp_f32. Expected: ~2-3 VALU fewer per score, faster forward.
- Changes: softmax.py online_softmax: probabilities and rescale via rocdl.exp2 (bare v_exp_f32).
- Result: forward 134.42 -> 135.85 TFLOPS (+1.1%), backward 61.98 -> 61.91 TFLOPS (-0.1%) ❌
- Decision: ROLLED BACK
- Detailed data: rounds/round-9/summary.md

### round-10 — issue a key step's P . V fragment reads before its MFMAs
- Validation level: full (13 shapes), same-GPU reference
- Hypothesis: Round 9 showed the forward is not VALU-bound; the ISA has every P . V MFMA behind its own lgkmcnt(0) on its two transpose reads. Reading all 4 d blocks' fragments of a key step first lets the reads overlap and the waits stagger.
- Changes: flash_fwd.py P . V: the V^T fragments of all DV / 32 d blocks of a key step are read into a list, then the MFMAs run.
- Result: forward 132.69 -> 135.96 TFLOPS (+2.5%), backward 61.91 -> 61.92 TFLOPS (+0.0%) ✅
- Decision: ACCEPTED
- Detailed data: rounds/round-10/summary.md

### round-11 — K/V double buffering in LDS (forward, gfx950 16-bit)
- Validation level: full (13 shapes), same-GPU reference
- Hypothesis: Each tile ran barrier -> synchronous K/V staging -> barrier -> compute, so a CTA computed nothing while its next tile loaded. gfx950's 160 KB LDS holds two 32 KB K/V stages for each of 2 CTAs per CU: issue tile n+1's loads, compute tile n, store tile n+1 into the other buffer, one barrier.
- Changes: flash_fwd.py (DB = gfx950 16-bit, no block lists): NBUF = 2 K / V LDS stages; load_kv / store_kv split; compute_one_n_block_db; prologue stages the first tile; the last tile re-stages itself into the idle buffer (no branch); rocdl.waves_per_eu = 2 keeps 2 waves / SIMD. Block-sparse, fp8 and gfx942 keep the single-buffer loop.
- Result: forward 134.47 -> 138.21 TFLOPS (+2.8%), backward 61.82 -> 62.04 TFLOPS (+0.4%) ✅
- Decision: ACCEPTED
- Detailed data: rounds/round-11/summary.md

### round-12 — issue all of a backward stage's global loads before its LDS stores (dQ, dK/dV)
- Validation level: full (13 shapes), same-GPU reference
- Hypothesis: The backward's _stage_rows staged each 16-byte pack as load -> wait -> LDS store, the serialization the forward lost in gfx950 round 7; dQ stages K and V, dK/dV stages Q and dO, for every block they visit. Loading both tiles before any store pays one load latency per stage.
- Changes: flash_bwd.py: _stage_rows split into _load_rows / _store_rows; both kernels load both staged tiles, then store. Shared code (gfx942 and gfx950).
- Result: forward 136.44 -> 136.65 TFLOPS (+0.2%), backward 61.68 -> 71.79 TFLOPS (+16.4%) ✅
- Decision: ACCEPTED
- Detailed data: rounds/round-12/summary.md

### round-13 — transpose reads for the backward's column views (dQ, dK, dV)
- Validation level: full (13 shapes), same-GPU reference
- Hypothesis: The backward's three products that reduce over an accumulator's rows (dQ = dS . K, dK = dS^T . Q, dV = P^T . dO) read A fragments of the transposed LDS views one 16-bit element at a time (8 per fragment), as the forward's P . V did before round 8.
- Changes: flash_bwd.py _Ops.a_from_cols_tr (gfx950, k_step 16): two LDSReadTrans16_64b reads per A fragment; with the bit-2/3 reduction order, read h covers stored rows 16 step + 4 (lane // 32) + 8 h + {0..3}; addresses through the tile's chunk ^ (row & 7) swizzle. Used for kt_cols (dQ), dot_cols (dV), qt_cols (dK). gfx942 keeps the element reads.
- Result: forward 134.72 -> 134.94 TFLOPS (+0.2%), backward 71.94 -> 85.44 TFLOPS (+18.8%) ✅
- Decision: ACCEPTED
- Detailed data: rounds/round-13/summary.md

### round-14 — refactor (no performance change): separate gfx942 and gfx950 backward kernels
- 2026-11-05 00:15. flash_bwd.py is now a dispatcher; flash_bwd_gfx942.py (32x32x8, element-wise column reads) and
  flash_bwd_gfx950.py (32x32x16, transpose reads, asserts gfx950) evolve separately from here (user request).
- Validation (same-GPU reference = previous commit): all 13 shapes within noise on both GPUs; tests 37 passed on both.
- Occupancy-2 probes before the split (gfx950, uncommitted): waves_per_eu=2 alone spills 704-728 B; + 32-row tiles
  172-268 B (dQ clean at 216 regs); + per-block K/V fragment reload 124-132 B but slower; + S->dV / dP->dK reorder
  316-328 B. gfx942: 288-1080 B in every variant. The spills are the loop-invariant K/V fragments reloaded from
  scratch each block. Chosen next (user): gfx950 dK/dV stages K and V in LDS (80 KB per CTA, 2 CTAs in 160 KB).

### round-15 — dK/dV at 2 waves per SIMD: K/V staged in LDS, shared swizzled LDS offsets, two-per-CU GQA split (gfx950)
- Validation level: full (13 shapes), same-GPU reference
- Hypothesis: The gfx950 dK/dV kernel held each lane's K/V B fragments in registers (64 per lane) on top of 128 accumulator registers, so it ran at 1 wave per SIMD (296-360 registers); the occupancy-2 hint alone spilled 704-728 B. Staging the CTA's K/V rows in LDS once (80 KB with the 32-row Q/dO tile, 2 CTAs in 160 KB) frees those registers. A first cut still spilled 164-288 B: ISA showed every ds_read_b128 had its own swizzled address register (~40, reloaded from scratch each block) and all 16 K/V fragments were loaded up front.
- Changes: flash_bwd_gfx950.py (gfx950 only): dK/dV SharedStorage = q, do (TM=32 rows) + k, v (TN=128 rows), staged once per CTA via _load_rows/_store_rows; per-row LSE / D' by lane shuffle instead of LDS arrays; _Ops.frag_offsets: a lane's 8 K-step offsets = (row*dim + 8 ((lane//32) ^ (row&7))) ^ const + const, shared by Q/dO and (+ 32 wave rows) K/V, reads issued at their MFMA; _Ops.tr_offsets / a_from_cols_tr_at precompute the transpose-read offsets per 32-column group; rocdl.waves_per_eu=2 on dQ and dK/dV; dkdv_tile_m 64 -> 32; _dkdv_split fills two CTAs per CU (up to four with MIN_SPLIT_WORK = 8192 query rows). dq_tile_n stays 64 (32 was -7% on window1k).
- Result: forward 135.43 -> 137.07 TFLOPS (+1.2%), backward 84.87 -> 103.19 TFLOPS (+21.6%) ✅
- Decision: ACCEPTED
- Detailed data: rounds/round-15/summary.md
