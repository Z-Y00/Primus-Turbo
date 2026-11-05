# Round 2 — ROLLED BACK: stage V transposed in LDS (forward)

## Hypothesis

The forward's P . V reads its V^T A-fragments from LDS one 16-bit element at a time
(4 `ds_read_u16` per MFMA, 128 per lane per 64-key tile vs 32 `ds_read_b64` for K).
Staging V transposed (`[DV, TN+4]`, keys contiguous) lets P . V read 4 keys per
`ds_read_b64`, like K. Expected: 20-40% faster forward on every shape; backward untouched.

## Single change

`flash_fwd.py` (bf16/fp16 only; fp8 keeps its layout): V LDS array `[DV, TN+4]`; staging
maps lanes to consecutive keys of one 8-wide d slice and writes the 8 elements with
16-bit LDS stores; P . V copies A fragments with the 64-bit atom used for K.

## Results

### Validation
- Time: 2026-11-03 20:57
- Validation level: quick (5 representative shapes)
- Tests: both FlyDSL test files were run (the summary line was not captured in the log; correctness also gated by the harness against Triton: all PASS)
- Raw artifacts: `artifacts/quick_validation.log`, `artifacts/benchmark.csv`

| shape | Check | fwd TFLOPS | bwd TFLOPS | fwd ms | bwd ms | fwd vs round 1 | bwd vs round 1 |
|---|---|---|---|---|---|---|---|
| causal_s8k | PASS | 99.2 | 60.0 | 5.540 | 22.894 | -16.9% | +0.2% |
| window1k_s8k | PASS | 88.4 | 75.2 | 1.458 | 4.283 | -16.9% | +0.2% |
| band1k_s8k | PASS | 113.0 | 87.1 | 2.279 | 7.393 | -13.3% | +0.1% |
| inkling_global_5doc | PASS | 49.9 | 16.9 | 1.420 | 10.480 | -23.4% | +0.3% |
| inkling_small_local_5doc | PASS | 25.0 | 16.6 | 0.580 | 2.186 | -16.7% | -6.5% |

### Aggregate (quick set)
- Forward geomean: 65.842 TFLOPS (round 1 on the same shapes: 79.803) -> -17.5%
- Backward geomean: 40.601 TFLOPS (round 1: 41.085) -> -1.2% (unchanged kernel; noise)

## Decision

`ROLLED BACK` — forward regressed 15-31% on every shape (>= 5% rule).

## Attribution

rocprofv3 on causal_s8k forward (`profiles/round2_vs_round1_causal_s8k_fwd.log`):

| counter | round 1 | round 2 |
|---|---|---|
| SQ_INSTS_LDS | 82.0 M | 37.3 M |
| SQ_INSTS_VALU | 491 M | 456 M |
| SQ_LDS_BANK_CONFLICT (cycles) | 1022 M | 1022 M |
| VGPR + AGPR | 68 + 132 = 200 | 84 + 180 = 264 |

The LDS instruction count fell as designed, but registers rose past 256 per lane, so
occupancy fell from 2 to 1 wave per SIMD; that outweighed the saved instructions. The
bank-conflict cycles are identical, so they do not come from V at all.

## Rollback Analysis
- Change made: V staged transposed, P . V A-fragments read 64 bits at a time.
- Expected effect: fewer LDS instructions in P . V, faster forward.
- Actual effect: LDS instructions -55%, forward 15-31% slower.
- Root cause: +64 registers (transposed staging keeps 8 scalars live per pack, and the
  b64 V fragments are held longer) halved occupancy; the real LDS cost is bank conflicts
  elsewhere.
- Lesson learned: the forward sits at 200 of 256 registers (2 waves/SIMD) — any change
  must stay under 256. The dominant LDS cost is ~1.02 G bank-conflict cycles (about
  3.4 M per CU, ~1.6 ms of the 4.2 ms kernel), from the K A-fragment reads: K rows are
  D = 128 halves = 64 dwords apart, so the 32 lanes reading 32 key rows at one column all
  hit the same bank (32-way).

## Real-training transfer check
- Bucket: K1 (kernel-internal LDS layout)
- Cache key (if any): no cache
- id(...) audit: n/a
- 4-step pen-and-paper trace hit rate: n/a
- Benchmark gain on this round: forward -17.5%
- Estimated real-training gain: same as benchmark (rolled back)
- Decision: REJECT (performance), not an over-fit

## Next direction

Round 3: remove the K-read bank conflicts by padding the K LDS rows by 8 halves
(16 bytes; keeps 16-byte staging stores aligned): bank = 4 * row + col, so a 32-lane
read spreads over the banks (4-way worst case instead of 32-way), with no extra registers.
