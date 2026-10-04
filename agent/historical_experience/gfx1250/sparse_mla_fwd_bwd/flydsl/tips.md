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
