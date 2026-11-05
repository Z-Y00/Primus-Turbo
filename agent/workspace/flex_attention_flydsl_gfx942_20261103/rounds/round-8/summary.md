# Round 8 — ROLLED BACK: transposed, swizzled V under waves_per_eu = 2 (forward)

## Hypothesis

Round 6's transposed V cut LDS instructions 42% but took registers to 288; Round 7 showed the
`waves_per_eu = 2` cap alone is neutral. Under the cap the layout should keep 2 waves/SIMD and
turn the LDS saving into forward time.

## Single change

Round 6's V^T staging and 64-bit P . V fragment reads, plus Round 7's
`value_attrs={"rocdl.waves_per_eu": 2, "rocdl.flat_work_group_size": "256,256"}` (whose
standalone effect was measured at 0%).

## Results

### Validation
- Time: 2026-11-04 13:10
- Node: a17-31 GPU 7 (a17-40 went offline mid-run; the first attempt's results were lost).
  Because the node changed, Round 5's accepted kernel was re-measured in the same container as
  the reference (`artifacts/round5_reference_a17-31.csv`).
- Validation level: quick
- Tests: 37 passed; harness correctness vs Triton: all PASS

| shape | Check | fwd TFLOPS | bwd TFLOPS | fwd ms | bwd ms | fwd vs round 5 (same node) | bwd vs round 5 |
|---|---|---|---|---|---|---|---|
| causal_s8k | PASS | 182.3 | 91.0 | 3.016 | 15.113 | +0.6% | -0.2% |
| window1k_s8k | PASS | 132.4 | 105.3 | 0.973 | 3.060 | -2.1% | -0.6% |
| band1k_s8k | PASS | 177.9 | 125.6 | 1.448 | 5.127 | -2.3% | +0.2% |
| inkling_global_5doc | PASS | 68.2 | 21.4 | 1.039 | 8.264 | -5.2% | +0.9% |
| inkling_small_local_5doc | PASS | 30.2 | 18.1 | 0.480 | 2.007 | -5.8% | -1.0% |

rocprofv3, causal_s8k forward: VGPR + AGPR 128 + 128 = 256 (cap held), LDS 32,768 B,
SQ_INSTS_LDS 52.2 M (round 5: 89.5 M), SQ_LDS_BANK_CONFLICT 136 M (round 5: 68 M).

### Aggregate (quick set, same node)
- Forward geomean: 97.603 TFLOPS (round 5: 100.612) -> -3.0%
- Backward geomean: 54.158 TFLOPS (round 5: 54.242) -> -0.2% (kernel unchanged)

## Decision

`ROLLED BACK` — forward -3% overall; inkling_global_5doc -5.2% and inkling_small_local_5doc
-5.8% (>= 5% rule).

## Attribution

With occupancy held, the 42% fewer LDS instructions buy nothing: LDS issue is no longer what
limits the forward. The transposed staging adds 8 scalar stores plus address math per 16-byte
pack and doubles the conflict cycles, which costs the Inkling shapes (shorter KV loops, so
staging is a larger share) a little more than it saves.

## Rollback Analysis
- Change made: transposed, swizzled V in LDS under a 2-waves/EU register cap.
- Expected effect: Round 6's LDS saving at unchanged occupancy -> faster forward.
- Actual effect: registers 256, LDS insts -42%, forward -3% (Inkling -5%).
- Root cause: the forward's binding limit is no longer LDS instruction issue.
- Lesson learned: third consecutive rollback (6, 7, 8) on the forward's LDS path. Per Rule 7,
  escalate to ISA-level inspection: find where the forward's cycles go (MFMA issue vs waits on
  global loads vs the online softmax's VALU) before another layout change.

## Real-training transfer check
- Bucket: K1
- Decision: REJECT (performance)

## Next direction

ISA-level inspection of the Round 5 forward (instruction mix per KV tile, s_waitcnt placement,
whether K/V global loads for tile n+1 overlap tile n's MFMAs: today staging is synchronous with
two barriers per tile), then the likely next lever: software-pipelined K/V prefetch.
