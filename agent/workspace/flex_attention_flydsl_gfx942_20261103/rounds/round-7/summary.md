# Round 7 — ROLLED BACK (neutral): waves_per_eu = 2 on the forward kernel

## Hypothesis

Rounds 2 and 6 lost because the transposed-V path took the forward past 256 registers
(one wave per SIMD). A `rocdl.waves_per_eu = 2` hint makes the compiler fit 256. On the
current kernel (232 registers) it should be neutral; this round measures the cap alone so
the next round can attribute the layout change cleanly.

## Single change

`flash_fwd.py`: the forward kernel call passes
`value_attrs={"rocdl.waves_per_eu": 2, "rocdl.flat_work_group_size": "256,256"}`.

## Results

### Validation
- Time: 2026-11-04 11:05
- Validation level: quick
- Harness correctness vs Triton: all PASS (test files run as before)
- Raw artifacts: `artifacts/quick_validation.log`, `artifacts/benchmark.csv`

| shape | Check | fwd TFLOPS | bwd TFLOPS | fwd ms | bwd ms | fwd vs round 5 | bwd vs round 5 |
|---|---|---|---|---|---|---|---|
| causal_s8k | PASS | 183.3 | 90.6 | 2.999 | 15.170 | -0.9% | +0.2% |
| window1k_s8k | PASS | 135.9 | 104.5 | 0.948 | 3.084 | -0.4% | -0.3% |
| band1k_s8k | PASS | 182.2 | 124.5 | 1.413 | 5.173 | -0.4% | -0.2% |
| inkling_global_5doc | PASS | 71.8 | 21.0 | 0.987 | 8.440 | -1.2% | -1.4% |
| inkling_small_local_5doc | PASS | 31.6 | 18.0 | 0.458 | 2.017 | -1.3% | -1.7% |

rocprofv3, causal_s8k forward: VGPR + AGPR 100 + 132 = 232 (unchanged), LDS 32,768 B,
SQ_INSTS_LDS 89.5 M, conflicts 68 M (unchanged).

### Aggregate (quick set)
- Forward geomean: 100.630 TFLOPS (round 5: 101.481) -> -0.8% (noise)
- Backward geomean: 53.659 TFLOPS (round 5: 54.029) -> -0.7% (kernel unchanged)

## Decision

`ROLLED BACK` — neutral (no aggregate improvement), as predicted; the register count is
unchanged, so the hint does nothing on its own here.

## Attribution

The kernel already fits 2 waves/SIMD, so the hint does not constrain allocation or schedule.

## Rollback Analysis
- Change made: waves_per_eu = 2 hint on the forward.
- Expected effect: neutral (enabler for the transposed-V layout).
- Actual effect: neutral, identical registers / LDS / counters.
- Root cause: no constraint to apply at 232 registers.
- Lesson learned: the hint's standalone effect is 0%, so Round 8 (transposed V under the hint)
  measures the layout alone.

## Real-training transfer check
- Bucket: K1 (compile hint)
- Decision: REJECT (no gain)

## Next direction

Round 8: Round 6's transposed, swizzled V staged under `waves_per_eu = 2`.
