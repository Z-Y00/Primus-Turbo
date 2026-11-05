# Round 6 — ROLLED BACK: transposed V in LDS with an XOR swizzle (forward)

## Hypothesis

Round 2's transposed V lost, but its padded tile took LDS to 33,792 B per CTA, the same
occupancy wall Round 3 hit; the register jump might have been a consequence. Staging V^T
with a chunk swizzle instead of padding keeps LDS at 32 KB. Expected: P . V reads 4 keys per
64-bit LDS read; ~40% fewer LDS instructions; faster forward on every shape.

## Single change

`flash_fwd.py` (bf16 / fp16): V LDS view `[DV, TN]` keys-contiguous composed with
`Swizzle<3, 3, 3>`; staging maps lanes to consecutive keys of one 8-wide d slice and stores 8
scalars at swizzled offsets; P . V copies its A fragments with the 64-bit atom used for K.

## Results

### Validation
- Time: 2026-11-04 10:52
- Validation level: quick
- Tests: 37 passed; harness correctness vs Triton: all PASS
- Raw artifacts: `artifacts/quick_validation.log`, `artifacts/benchmark.csv`

| shape | Check | fwd TFLOPS | bwd TFLOPS | fwd ms | bwd ms | fwd vs round 5 | bwd vs round 5 |
|---|---|---|---|---|---|---|---|
| causal_s8k | PASS | 139.4 | 90.5 | 3.943 | 15.191 | -24.7% | +0.1% |
| window1k_s8k | PASS | 113.8 | 105.1 | 1.133 | 3.065 | -16.6% | +0.3% |
| band1k_s8k | PASS | 154.2 | 124.9 | 1.670 | 5.157 | -15.7% | +0.1% |
| inkling_global_5doc | PASS | 56.9 | 21.3 | 1.245 | 8.340 | -21.7% | -0.3% |
| inkling_small_local_5doc | PASS | 27.2 | 18.6 | 0.533 | 1.949 | -15.2% | +1.7% |

rocprofv3, causal_s8k forward: SQ_INSTS_LDS 89.5 M -> 52.2 M; SQ_LDS_BANK_CONFLICT 68 M -> 136 M
cycles; LDS 32,768 B (unchanged); VGPR + AGPR 100 + 132 = 232 -> 128 + 160 = 288.

### Aggregate (quick set)
- Forward geomean: 82.351 TFLOPS (round 5: 101.481) -> -18.9%
- Backward geomean: 54.240 TFLOPS (round 5: 54.029) -> +0.4% (kernel unchanged)

## Decision

`ROLLED BACK` — forward -14% to -33% on every shape.

## Attribution

LDS stayed at 32 KB, yet registers still rose to 288 (> 256, one wave per SIMD), so the
register growth belongs to the transposed path itself: 8 live scalars and 8 addresses per
staged pack, and 64-bit V^T fragments the compiler hoists ahead of the P . V MFMAs. The
element stores also doubled the conflict cycles (the chunk swizzle shifts each d row's
chunks, so a wave's 2-byte stores no longer fill whole rows in order).

## Rollback Analysis
- Change made: V staged transposed, swizzled; 64-bit P . V fragment reads.
- Expected effect: fewer LDS instructions, faster forward.
- Actual effect: LDS instructions -42%, forward 14-33% slower.
- Root cause: 288 registers -> occupancy halved; not the LDS size (Round 2's diagnosis was right).
- Lesson learned: the transposed path needs a register cap. FlyDSL 0.3.4.1 takes
  `value_attrs={"rocdl.waves_per_eu": 2, "rocdl.flat_work_group_size": "256,256"}` on the
  kernel call; test that cap alone first (one change per round), then retry this layout under it.

## Real-training transfer check
- Bucket: K1
- Cache key (if any): no cache
- Decision: REJECT (performance), not an over-fit

## Next direction

Round 7: `rocdl.waves_per_eu = 2` (and the flat work-group size) on the forward kernel alone.
