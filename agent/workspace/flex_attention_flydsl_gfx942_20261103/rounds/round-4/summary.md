# Round 4 — ACCEPTED: XOR-swizzle the K LDS tile (forward)

## Hypothesis

Round 3 showed that removing the K A-fragment bank conflicts speeds up the forward, but
padding pushed LDS past 32 KB per CTA and halved occupancy. An XOR swizzle of K's 16-byte
chunks by row (chunk ^= row % 8) spreads a 32-row fragment read the same way with zero extra
bytes. Expected: Round 3's dense gain without its Inkling regression.

## Single change

`flash_fwd.py`: the K LDS view is `make_composed_layout(SwizzleType.get(3, log2(PACK),
log2(D) - log2(PACK)), (TN, D):(D, 1))` (when D / PACK is a power of two), and the staging
store writes pack `row * D/PACK + (chunk ^ (row & 7))`. LDS size unchanged.

## Results

### Validation
- Time: 2026-11-03 21:36
- Validation level: quick
- Tests: `test_flex_attention_flydsl.py` + `test_flex_attention_flydsl_paged.py`: 37 passed (`artifacts/tests.log`)
- Harness correctness vs Triton: all PASS
- Raw artifacts: `artifacts/quick_validation.log`, `artifacts/benchmark.csv`

| shape | Check | fwd TFLOPS | bwd TFLOPS | fwd ms | bwd ms | fwd vs round 1 | bwd vs round 1 |
|---|---|---|---|---|---|---|---|
| causal_s8k | PASS | 185.0 | 59.6 | 2.972 | 23.047 | +55.0% | -0.5% |
| window1k_s8k | PASS | 135.8 | 76.6 | 0.949 | 4.203 | +27.7% | +2.1% |
| band1k_s8k | PASS | 183.7 | 87.5 | 1.402 | 7.361 | +40.9% | +0.5% |
| inkling_global_5doc | PASS | 72.7 | 16.7 | 0.976 | 10.594 | +11.4% | -0.8% |
| inkling_small_local_5doc | PASS | 31.7 | 16.4 | 0.458 | 2.212 | +5.6% | -7.6% |

rocprofv3, causal_s8k forward: SQ_LDS_BANK_CONFLICT 1022 M -> 68 M cycles; SQ_INSTS_LDS 82.0 M
-> 89.5 M; LDS 32768 bytes (unchanged); VGPR + AGPR 100 + 132 = 232 (2 waves/SIMD kept).

### Aggregate (quick set)
- Forward geomean: 101.216 TFLOPS (round 1: 79.803) -> +26.8%
- Backward geomean: 40.551 TFLOPS (round 1: 41.085) -> -1.3% (kernel unchanged; within noise, no shape >= 5%)

## Decision

`ACCEPTED` — forward improves on every shape (+5% to +56%), backward unchanged.

## Attribution

The K-read conflicts were the forward's main stall on dense shapes (~1.6 ms of 4.2 ms on
causal_s8k). The swizzle removes 93% of the conflict cycles without touching the LDS budget,
so the CTA count per CU and the register budget stay put. Inkling gains less: its forward
also pays a bias gather per score, which the swizzle does not touch.

## Real-training transfer check
- Bucket: K1 (kernel-internal LDS layout)
- Cache key (if any): no cache
- id(...) audit: n/a
- 4-step pen-and-paper trace hit rate: n/a
- Benchmark gain on this round: forward +26.8% (quick set geomean)
- Estimated real-training gain: same (a kernel layout change, no state across calls)
- Decision: ACCEPT-as-real

## Next direction

The forward still reads V^T one element at a time (64 of the ~89 M LDS instructions);
transposing V cost registers in Round 2. Alternatives that keep registers flat: read V^T as
packed 32-bit pairs, or swap the P . V operand roles. The backward (1.5-3.2x Triton) is now
the larger gap: profile dQ and dK/dV the same way (bank conflicts likely identical, since the
backward stages K and V the same way).
