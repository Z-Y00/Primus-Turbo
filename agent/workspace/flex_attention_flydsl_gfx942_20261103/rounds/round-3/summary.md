# Round 3 — ROLLED BACK: pad K LDS rows by 16 bytes (forward)

## Hypothesis

Round 2's profile showed ~1.02 G LDS bank-conflict cycles in the causal_s8k forward, from
K A-fragment reads (32 key rows 64 dwords apart -> one bank). Padding each K row by 16
bytes (stride D + 8 bf16) spreads a fragment read over the banks (4-way worst case).
Expected: most of the conflict cycles gone, faster forward on every shape, no register cost.

## Single change

`flash_fwd.py`: K LDS array `[TN, D + PACK]`; staging writes and the A-fragment view use
the padded stride.

## Results

### Validation
- Time: 2026-11-03 21:13
- Validation level: quick
- Tests: run (summary line not captured, see Next direction); harness correctness vs Triton: all PASS
- Raw artifacts: `artifacts/quick_validation.log`, `artifacts/benchmark.csv`

| shape | Check | fwd TFLOPS | bwd TFLOPS | fwd ms | bwd ms | fwd vs round 1 | bwd vs round 1 |
|---|---|---|---|---|---|---|---|
| causal_s8k | PASS | 137.1 | 59.5 | 4.011 | 23.106 | +14.8% | -0.7% |
| window1k_s8k | PASS | 112.1 | 75.3 | 1.150 | 4.276 | +5.4% | +0.4% |
| band1k_s8k | PASS | 146.8 | 86.6 | 1.754 | 7.437 | +12.7% | -0.5% |
| inkling_global_5doc | PASS | 56.4 | 17.1 | 1.256 | 10.390 | -13.4% | +1.2% |
| inkling_small_local_5doc | PASS | 26.8 | 17.9 | 0.541 | 2.029 | -10.7% | +0.8% |

rocprofv3, causal_s8k forward: SQ_LDS_BANK_CONFLICT 1022 M -> 68 M cycles; SQ_INSTS_LDS unchanged
(82.0 M); LDS per CTA 32768 -> 33792 bytes; VGPR + AGPR 200 -> 72 + 192 = 264.

### Aggregate (quick set)
- Forward geomean: 80.647 TFLOPS (round 1: 79.803) -> +1.1%
- Backward geomean: 41.168 TFLOPS (round 1: 41.085) -> +0.2% (kernel unchanged)

## Decision

`ROLLED BACK` — dense forward +7-15%, but inkling_global_5doc forward -13% and
inkling_small_local_5doc -11% (>= 5% regression rule).

## Attribution

The conflicts are gone (15x fewer cycles), which is the dense gain. But the 1 KB of padding
pushed LDS from exactly 32 KB to 33 KB per CTA, so a CU (64 KB) holds one CTA instead of
two: occupancy fell from 2 to 1 wave per SIMD, and the compiler, no longer bound to 2 waves,
spent 264 registers. Inkling's forward (a bias gather per score, more latency to hide)
loses more from the occupancy drop than it gains from the conflicts. Round 2's padded V
(33 KB) hit the same wall.

## Rollback Analysis
- Change made: K rows padded by 16 bytes.
- Expected effect: no bank conflicts on K reads, faster forward everywhere.
- Actual effect: conflicts -93%, dense forward faster, Inkling forward slower.
- Root cause: LDS 32 KB -> 33 KB per CTA halves CTAs per CU.
- Lesson learned: the forward's LDS budget is exactly 32 KB for 2 CTAs/CU; layout fixes
  must not add bytes. Use an XOR swizzle (FlyDSL `make_composed_layout` with
  `SwizzleType.get(3, log2(PACK), log2(D) - log2(PACK))`), same read spread, zero bytes.

## Real-training transfer check
- Bucket: K1 (kernel-internal LDS layout)
- Cache key (if any): no cache
- Benchmark gain on this round: forward +1.1% (mixed)
- Decision: REJECT (per-shape regression), not an over-fit

## Next direction

Round 4: XOR-swizzle the K LDS tile's 16-byte chunks by row (no extra LDS). Also print the
pytest summary with `tail -c` so the correctness gate is visible in the log.
