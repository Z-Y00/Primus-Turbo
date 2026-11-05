# Round 10 — ACCEPTED: issue a key step's P . V fragment reads before its MFMAs

## Hypothesis

Round 9 showed the forward is not VALU-bound; the ISA has every P . V MFMA behind its own lgkmcnt(0) on its two transpose reads. Reading all 4 d blocks' fragments of a key step first lets the reads overlap and the waits stagger.

## Single change

flash_fwd.py P . V: the V^T fragments of all DV / 32 d blocks of a key step are read into a list, then the MFMAs run.

## Results

- Validation: full (13 shapes) on a17-31's 8 GPUs; each shape's reference and candidate ran on the same GPU
  (`artifacts/validation.log`, gpu map at the end); tests before benchmarks.
- Raw artifacts: `artifacts/benchmark.csv`, `artifacts/round8_reference_same_gpu.csv`

| shape | Check | ref fwd ms | fwd ms | fwd change | ref bwd ms | bwd ms | bwd change | fwd vs Triton | bwd vs Triton |
|---|---|---|---|---|---|---|---|---|---|
| causal_s4k | PASS | 1.017 | 0.993 | +2.5% | 6.895 | 6.908 | -0.2% | 1.63x | 2.29x |
| causal_s8k | PASS | 1.578 | 1.528 | +3.3% | 12.031 | 11.991 | +0.3% | 1.50x | 2.12x |
| window1k_s8k | PASS | 0.570 | 0.509 | +12.0% | 2.289 | 2.269 | +0.9% | 1.66x | 1.69x |
| band1k_s8k | PASS | 0.763 | 0.748 | +2.0% | 3.765 | 3.790 | -0.7% | 1.40x | 1.04x |
| prefix_lm_s8k | PASS | 1.784 | 1.763 | +1.2% | 11.911 | 11.960 | -0.4% | 1.63x | 1.66x |
| inkling_global_1doc | PASS | 1.737 | 1.726 | +0.6% | 10.647 | 10.624 | +0.2% | 0.93x | 1.93x |
| inkling_global_5doc | PASS | 0.654 | 0.647 | +1.1% | 4.568 | 4.577 | -0.2% | 0.95x | 1.90x |
| inkling_local_1doc | PASS | 0.439 | 0.433 | +1.3% | 1.905 | 1.897 | +0.4% | 0.97x | 1.59x |
| inkling_local_5doc | PASS | 0.479 | 0.472 | +1.6% | 2.480 | 2.504 | -0.9% | 1.06x | 1.83x |
| inkling_small_global_1doc | PASS | 0.991 | 0.983 | +0.8% | 5.897 | 5.898 | -0.0% | 0.74x | 2.05x |
| inkling_small_global_5doc | PASS | 0.504 | 0.498 | +1.3% | 2.558 | 2.485 | +2.9% | 1.01x | 1.51x |
| inkling_small_local_1doc | PASS | 0.305 | 0.300 | +1.6% | 1.123 | 1.127 | -0.3% | 1.07x | 1.36x |
| inkling_small_local_5doc | PASS | 0.347 | 0.335 | +3.4% | 1.421 | 1.446 | -1.7% | 1.15x | 1.51x |

- Forward geomean: 132.688 -> 135.964 TFLOPS (+2.5%)
- Backward geomean: 61.907 -> 61.917 TFLOPS (+0.0%)

## Decision

`ACCEPTED`

## Attribution

ISA: 8 transpose reads, then lgkmcnt(6/4/2/0) between the 4 MFMAs. Forward +0.6% to +3.4% on all 13 shapes (window +12%), geomean +2.5%: the per-MFMA LDS latency was a real but modest share; the loop still has two barriers per tile around synchronous K/V staging.

## Real-training transfer check
- Bucket: K1 (kernel-internal / launch configuration); no cache
- Estimated real-training gain: same as benchmark
- Decision: ACCEPT-as-real

## Next direction

K/V double buffering in LDS (stage tile n+1 while computing tile n): gfx950's 160 KB LDS fits two 32 KB stages per CTA at 2 CTAs / CU.
