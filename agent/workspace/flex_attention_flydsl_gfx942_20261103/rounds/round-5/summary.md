# Round 5 — ACCEPTED: XOR-swizzle the backward's LDS tiles

## Hypothesis

The dQ kernel stages K / V and the dK/dV kernel Q / dO row-major in LDS ([64, 128] bf16)
and reads A fragments of 32 rows at once: the same 32-way bank conflict Round 4 removed from
the forward. dK/dV runs at one wave per SIMD (328 registers, 33 KB LDS), so it cannot hide
the stalls. Expected: backward faster on every shape, forward untouched.

## Single change

`flash_bwd.py`: `_lds_view` composes every view of a staged tile (row view and transposed
column view alike, over the same linear offsets) with `Swizzle<3, 3, log2(dim) - 3>`, and
`_stage_rows` stores each 16-byte chunk at `row * chunks + (chunk ^ (row & 7))`. No LDS bytes added.

## Results

### Validation
- Time: 2026-11-03 21:59
- Validation level: quick
- Tests: 37 passed (both FlyDSL test files)
- Harness correctness vs Triton: all PASS
- Raw artifacts: `artifacts/quick_validation.log`, `artifacts/benchmark.csv`

| shape | Check | fwd TFLOPS | bwd TFLOPS | fwd ms | bwd ms | fwd vs round 4 | bwd vs round 4 |
|---|---|---|---|---|---|---|---|
| causal_s8k | PASS | 185.1 | 90.4 | 2.971 | 15.200 | +0.0% | +51.6% |
| window1k_s8k | PASS | 136.4 | 104.7 | 0.945 | 3.076 | +0.5% | +36.7% |
| band1k_s8k | PASS | 183.0 | 124.8 | 1.408 | 5.161 | -0.4% | +42.6% |
| inkling_global_5doc | PASS | 72.7 | 21.3 | 0.976 | 8.319 | +0.0% | +27.4% |
| inkling_small_local_5doc | PASS | 32.1 | 18.3 | 0.452 | 1.983 | +1.2% | +11.6% |

Kernel trace, causal_s8k backward: dQ ~6.5 -> 4.5 ms, dK/dV ~15.7 -> 10.0 ms. Registers
(VGPR + AGPR) now dQ 128 + 304, dK/dV 128 + 384 (LDS 32768 / 33280 unchanged).

### Aggregate (quick set)
- Forward geomean: 101.481 TFLOPS (round 4: 101.216, baseline 79.803)
- Backward geomean: 54.029 TFLOPS (round 4: 40.551) -> +33.2% (vs baseline +31.5%)

## Decision

`ACCEPTED` — backward +12% to +52% on every shape, forward unchanged.

## Attribution

As in the forward, the A-fragment reads of the staged tiles were 32-way conflicted; the
backward has more of them per tile (S, dP, dQ / dK, dV all read staged operands), so the gain
is larger. Inkling gains least: its backward also pays the bias gather, the hook's scattered
store (dQ), and its 5-document varlen grid has idle tiles.

## Real-training transfer check
- Bucket: K1 (kernel-internal LDS layout)
- Cache key (if any): no cache
- Benchmark gain on this round: backward +33.2% (quick set geomean)
- Estimated real-training gain: same
- Decision: ACCEPT-as-real

## Next direction

dK/dV is still ~2/3 of the backward and runs one wave per SIMD (512 registers per lane in use,
LDS 33,280 B > 32 KB). Options: cut the dK/dV register footprint (accumulators dK, dV for
128 keys x 128 dims per CTA = 256 fp32 per lane) by halving the CTA's key tile with 2x the
CTAs; or drop the LSE / D' LDS arrays (512 B) to fit 32 KB.
