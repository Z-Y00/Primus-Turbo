# Tips — sparse MLA fwd/bwd, FlyDSL, gfx1250

### 2026-10-04 12:14 round-2 — ACCEPTED
- Context: CSR inverse of the top-k map for the deterministic dkv gather.
- Signal: torch profiler showed a DtoH memcpy + histogram per backward; `torch.bincount` on GPU syncs to find max.
- Takeaway: build `inv_ptr` with `torch.searchsorted(sorted_keys, arange(n+1), out_int32=True)` from `torch.sort(stable=True)` values; identical CSR, no host sync. +3.7% step on DSV4 shapes.
- Applicability: any CSR / segment build on GPU where bincount/unique would otherwise be used inside the training step.
