# Tips — sparse MLA fwd/bwd, FlyDSL, gfx1250

### 2026-10-04 12:14 round-2 — ACCEPTED
- Context: CSR inverse of the top-k map for the deterministic dkv gather.
- Signal: torch profiler showed a DtoH memcpy + histogram per backward; `torch.bincount` on GPU syncs to find max.
- Takeaway: build `inv_ptr` with `torch.searchsorted(sorted_keys, arange(n+1), out_int32=True)` from `torch.sort(stable=True)` values; identical CSR, no host sync. +3.7% step on DSV4 shapes.
- Applicability: any CSR / segment build on GPU where bincount/unique would otherwise be used inside the training step.

### 2026-10-04 12:17 round-3 — ACCEPTED
- Context: stable torch.sort of T*topk kv indices (CSR build).
- Signal: rocprim radix sort 0.133 ms for 524K int32 keys.
- Takeaway: cast keys to int16 when the key range allows; the radix sort runs half the passes (0.049 ms) and the stable permutation is identical.
- Applicability: any torch.sort/argsort on small-range integer keys on ROCm.

### 2026-10-04 12:25 round-4 — ACCEPTED
- Context: sparse-MLA forward (gather KV rows to LDS, 16 heads/wave, transposed S^T / O^T).
- Signal: kernel-only sweep: 128-head WG (8 waves) bn64 2349 us vs bn32 1414 us at topk 1152; 64-head WG prefers bn64.
- Takeaway: the right KV tile depends on waves/WG — sweep block_k per heads_per_wg instead of "bigger tile when divisible".
- Applicability: FlyDSL gfx1250 attention-style kernels with gather prefetch in registers.

### 2026-10-04 12:31 round-5 — ACCEPTED
- Context: gfx1250 node practical HBM copy BW ~7.4 TB/s (r+w); per-token attention backward with ~1 MB/token traffic.
- Signal: removing 128 KB/token of reads gave +3-6% on H128 shapes, ~0 on H64.
- Takeaway: measure the copy BW first — gfx1250 kernels with per-token staging are bandwidth-sensitive at short top-k; never re-read from HBM what is already staged in LDS. H64 (4 waves/CU) did not benefit: it is latency-bound, fix occupancy first.
- Applicability: per-token / per-row fused backward kernels on gfx1250.

### 2026-10-04 12:37 round-6 — ACCEPTED
- Context: per-token fused attention backward, one workgroup per token, LDS-limited to 1 WG per CU.
- Signal: H64 per-tile time ≈ H128 per-tile time at half the FLOPs; 580 VGPRs, 4 waves/CU.
- Takeaway: when LDS pins 1 WG/CU, keep 8 waves per WG regardless of head count — split the per-head-group work (slot sub-tiles, dQ d-range) across 2 waves; it also halves accumulator VGPRs. +10-12% on H64 bwd.
- Applicability: gfx1250 kernels where a WG's wave count follows a problem dim (heads) that can be small.

### 2026-10-04 12:46 round-7 — ACCEPTED
- Context: scattered-row gather (CSR) over a multi-GB bf16 intermediate on gfx1250.
- Signal: the same compiled gather ran 2.7x faster when the buffer it reads spans < ~2 GB; 2.3 GB chunks got no speedup. LLC is only ~256-384 MB (copy BW 10-11 TB/s below 256 MB, 7.4 TB/s above).
- Takeaway: keep randomly-accessed buffers under ~1.5-2 GB per kernel launch (chunk the work); also size per-token-workgroup chunks as multiples of the CU count when LDS pins 1 WG/CU — a 1366-token chunk on 256 CUs cost ~8% from wave quantization.
- Applicability: any gather/scatter-heavy kernel on gfx1250 with multi-GB working sets.

### 2026-10-04 12:51 round-8 — ACCEPTED
- Context: FlyDSL gfx1250 kernels with a 4-wave (128-thread) workgroup.
- Signal: same per-wave work compiled to 999 VGPRs at 4 waves/WG vs ~500 at 8 waves/WG.
- Takeaway: with small workgroups the backend may use the full 1024-VGPR file (occupancy 1). Pass `value_attrs={"rocdl.waves_per_eu": 2}` at launch to cap at 512 and fit 2 WGs/CU; pair it with a smaller tile if the kernel would spill heavily (bn64+wpe2 was 2x slower, bn32+wpe2 15-25% faster). wpe 3/4 spill badly.
- Applicability: any gfx1250 FlyDSL kernel whose VGPR count jumps above 512 with a 4-wave workgroup.

### 2026-10-04 13:20 round-9 — ACCEPTED
- Context: CSR segmented-sum (dKV gather) where a few rows hold most entries (compressed pool).
- Signal: one-program-per-row gather 4.6x slower on cr128 than cr0 at similar bytes.
- Takeaway: split only heavy rows (> SEG entries) into fixed blocks of the sorted entry list, write per-block partials, add them in block order in a fix-up kernel (deterministic). Keep light rows on a 1-program-per-row path in the same launch — a pure fixed-block design was ~2x slower on short uniform rows (longer dependent-load chain + serial row loop).
- Applicability: any deterministic scatter-to-gather (inverted index) reduction with skewed row lengths.

### 2026-10-04 14:15 round-11 — ACCEPTED
- Context: WMMA-bound FlyDSL kernels (attention fwd/bwd) on gfx1250.
- Signal: free compiler knob listed in the FlyDSL arch-gfx1250 notes.
- Takeaway: `flyc.compile[{"llvm_options": {"amdgpu-expert-scheduling-mode": True}}](launch, ...)` gave +3..7% on every shape (largest on compute-heavy ones) with identical VGPRs and bitwise-same-quality results; verify `hwreg(HW_REG_WAVE_SCHED_MODE, 0, 2), 2` in `21_final_isa.s`. `amdgpu-sched-strategy=coexec` was neutral. Try it first on any new gfx1250 WMMA kernel.
- Applicability: any gfx1250 (gfx12+) compute-bound kernel.

### 2026-10-04 15:30 round-13 — REJECTED
- Context: `rocdl.global_load_async_to_lds_b128` + `s_wait_asynccnt` in a large (500-VGPR) FlyDSL kernel compiled with `amdgpu-expert-scheduling-mode`.
- Signal: GPU memory access fault at address nil; same kernel correct without expert mode; a tiny async-copy kernel works in both modes.
- Takeaway: async global->LDS copies and expert scheduling mode do not mix in the current compiler (the address VGPRs are likely clobbered before the async read; SCHED_MODE 2 leaves those hazards to software). Without expert mode the async gather removed 64 staging VGPRs and the spills, but expert mode alone was worth more (+5%).
- Applicability: any gfx1250 kernel combining async/TDM LDS copies with expert scheduling — test both modes.

### 2026-10-04 16:30 round-14 — REJECTED (re-profile reference numbers)
- Context: roofline numbers for gfx1250 (256 CUs, sclk 2.4 GHz) measured with FlyDSL microbenchmarks (campaign `rounds/round-14/artifacts`).
- Takeaway: bf16 WMMA 16x16x32 peak ~3.45 PFLOPS (0.34 WMMA/clk/CU); LDS ds_load_b128 ~350 B/clk/CU, ds_load_tr16_b128 ~257 B/clk/CU. rocprofv3 WMMA counters read 0 on this stack, so use timing probes. hipBLASLt bf16 GEMM is untuned (127 TF), not a usable reference. `amdgpu-sched-strategy` max-ilp / max-memory-clause / iterative-* were all worse than the default (iterative-minreg produced wrong results).
- Applicability: any gfx1250 kernel roofline estimate.

### 2026-10-04 14:45 round-15 — REJECTED
- Context: attention forward on gfx1250 with every wave re-reading the shared K/V LDS tile (2 waves/SIMD, ~500 VGPRs).
- Signal: halving per-wave K/V LDS reads by pairing waves (2 head groups per wave, d split, S partial exchange) made it 10-25% slower, 6-21% even with the extra barrier removed.
- Takeaway: on paper LDS bandwidth (b128 ~350, tr16 ~257 B/clk/CU) looks like the floor, but these kernels are issue-bound; adding per-wave VALU/TRANS work (duplicated softmax) costs more than the saved LDS reads.
- Applicability: any LDS-sharing restructure of WMMA attention kernels on gfx1250.

### 2026-10-04 15:40 round-16 — REJECTED (aiter OPUS comparison + TDM gather)
- Context: sparse-MLA forward on gfx1250 vs aiter's prebuilt OPUS bf16 sparse-prefill code object (`hsa/gfx1250/mla_v4_opus/*.co`; loadable via hipModuleLoad + hipDrvLaunchKernelEx with the pinned 112-byte kargs, see campaign `rounds/round-16/artifacts/opus_bench.py`).
- Signal: OPUS is ~1.7x faster (pro cr4 0.774 vs 1.328 ms). It runs 4 waves x 16 heads per WG at 898 VGPRs (1 wave/SIMD), 290 KB LDS, 64-key tiles, TDM gather (`tensor_load_to_lds` with 8 SGPR row indices from `s_buffer_load_b512`). Porting only the TDM gather into our 2-waves/SIMD kernel was 4-17% slower; OPUS-like 1-wave layouts in our compiler-scheduled code were 1.5x slower (stall on nearly every LDS fragment load).
- Takeaway: the OPUS win is a hand-pipelined single-wave kernel (deep LDS->register fragment prefetch), not the loader. TDM pitfalls: pred-off gathers don't count toward tensorcnt and all-OOB gathers complete early, so a count-based ring must drain with `s_wait_tensorcnt 0` at the tail. TDM gather pads LDS rows via the descriptor (interval 256 dw, amount 4 dw -> 1040 B pitch); `-1` indices are OOB and land as zeros.
- Applicability: any gfx1250 gather-attention kernel considering TDM or a 1-wave/SIMD layout.

### 2026-10-04 20:50 round-17 — ACCEPTED (single-wave forward learned from OPUS asm)
- Context: FlyDSL WMMA attention forward at one wave per SIMD (`waves_per_eu=1`) with a TDM gather ring.
- Signal: the compiler put two LDS loads + `s_wait_dscnt` right before every WMMA (no lookahead) and regrouped interleaved chains when prefetch was deep; debug runs without LDS loads were 32% faster.
- Takeaway: (1) prefetch LDS operands in the source (a Python queue of fragments N steps ahead) and pin the order with `rocdl.sched_barrier(0)` every few steps — prefetch 8 / pin 4 was best; (2) software-pipeline QK(t+1) against PV(t) in one block; (3) spend the 1024-VGPR file on more heads per wave (32 = two 16-head groups) so each LDS fragment feeds 2 WMMAs — the single biggest win (pro cr4 fwd 1.33 -> 0.93 ms, 950 VGPRs, no spills); (4) gfx1250 has no LDS bank-conflict counters; padding sweeps moved < 2%; (5) 16-bit TDM gather indices (dword0 `0x80000001`, 16 rows/op, two indices per dword) halve the op count against the 3-ops/wave queue; deeper rings lost (TDM LDS writes compete with operand reads); (6) expert scheduling mode miscompiled one VALU/WMMA interleaving (non-deterministic wrong results, correct with expert off) — re-verify every new interleaving several times.
- Applicability: any gfx1250 1-wave/SIMD WMMA kernel reading operands from LDS.

### 2026-10-04 21:15 round-18 — REJECTED
- Context: one-wave/SIMD WMMA attention forward on gfx1250 (expert scheduling mode).
- Signal: FA3-style intra-wave pipelining (softmax + O rescale of tile t spliced between the independent QK(t+1) WMMAs) was verified in the ISA but made the forward 1-2% slower.
- Takeaway: a wave's own VALU/TRANS work does not hide under its WMMAs; softmax cost here is issue cost. Reduce instruction count (lazy rescale, fewer selects) rather than reorder.
- Applicability: any single-wave WMMA kernel considering intra-wave softmax/GEMM overlap on gfx1250.

### 2026-10-04 21:30 OPUS asm study (no round) — where its softmax cycles go
- Context: aiter OPUS gfx1250 sparse-prefill forward (`opus_mla_v4_prefill_a16w16_16mx4_64nx1.co`, cy1 kernel), steady-state loop.
- Signal: its softmax runs as a contiguous block with no WMMAs inside (no intra-wave softmax/WMMA overlap, consistent with round 18).
- Takeaway (candidates, not yet tried): (1) thresholded lazy rescale (FA4-style): `growth = scale*tile_max - m_run`; if `growth <= 8.0` on every lane (`v_cmp_ge` + `s_cmp_eq vcc, exec` + `s_cbranch_vccnz`) keep the stale max and skip alpha + the 128 `v_pk_mul` O rescale — safe since exp2(s - m) <= 2^8; (2) lean exp path: one `v_fma_f32 x, s_scale, -m` per score alternated with `v_exp_f32` (VALU/TRANS co-issue), vs our pk_mul + cndmask + sub + back-to-back exps + v_nop; (3) split barrier: `s_barrier_signal`, the last PV WMMAs from already-loaded registers, then `s_barrier_wait`. OPUS also sets SCHED_MODE 2 (same as our expert mode).
- Applicability: next steps for the gfx1250 sparse-MLA forward; (1)-(3) apply to any single-wave WMMA attention forward.

### 2026-10-11 18:20 round-19 — REJECTED
- Context: one-wave/SIMD attention forward with 32 heads per wave (two 16-head groups).
- Signal: OPUS-style thresholded lazy rescale (ballot + wave-uniform `scf.if`, threshold 8 log2) was neutral; never rescaling at all was only 1.3% faster; forcing the branch every tile cost 2%.
- Takeaway: measure the bound first — once a wave owns more heads, per-tile softmax/rescale work is amortized over more WMMAs and OPUS's softmax tricks shrink to ~1%. FlyDSL recipe for wave-uniform branches with results: `llvm.call_intrinsic(i32, "llvm.amdgcn.ballot.i32", [i1])` then `scf.IfOp(cond, types, has_else=True)` with `scf.YieldOp` in both regions.
- Applicability: any gfx1250 attention kernel considering lazy rescale.

### 2026-10-11 18:16 round-20 — ACCEPTED (backward LDS prefetch)
- Context: fused per-token attention backward on gfx1250, 8 waves / WG (2 waves/SIMD, 512-VGPR cap).
- Signal: ISA had ~1 `s_wait_dscnt` per WMMA; source-level prefetch 8 + `sched_barrier(0)` every 4 steps gave -4..-5% bwd kernel time on H64 (363 VGPRs) but spilled on H128 (452 VGPRs -> 512 + 9..41 spills, up to 2.5x slower).
- Takeaway: the round-17 prefetch recipe needs ~64+ free VGPRs; gate it on the register budget per config. Pins without prefetch only constrain the scheduler (-11%), and prefetch without pins is undone by the backend (no gain) — they only work together. Split a big step list into `(load, mma)` steps where shared operands (A fragment for several B, B for several A) are loaded by the first step of their group and kept in a Python dict.
- Applicability: any gfx1250 FlyDSL WMMA kernel; check `.vgpr_count`/`.vgpr_spill_count` per config before enabling deep prefetch.
