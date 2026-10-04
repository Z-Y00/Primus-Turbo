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
