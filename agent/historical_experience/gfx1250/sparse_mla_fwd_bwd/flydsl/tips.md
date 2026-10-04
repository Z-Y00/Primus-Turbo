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
