"""Quick validation for the FlyDSL flex attention campaign (correctness vs Triton + timing).

Each shape runs turbo.ops flex attention with kernel_options BACKEND=FLYDSL. Correctness:
output and every gradient against the TRITON backend on the same inputs (relative max
error <= 2e-2). Timing: median of CUDA-event samples, forward alone and backward alone
(autograd.grad on a retained graph). FLOPs count the kept (query, key) pairs:
forward 4 * Hq * D * pairs, backward 2.5x that.

    python quick_test_bench.py [--shapes all|quick|name,name] [--summary-csv out.csv]
                               [--triton-timing]
"""

import argparse
import csv
import math
import os
import statistics
import sys

import torch
import triton

REPO = os.environ.get("TURBO_REPO", "/tmp/t")
sys.path.insert(0, REPO)

import primus_turbo.pytorch as turbo  # noqa: E402
from tests.pytorch.ref import inkling_attention_ref as inkling  # noqa: E402

DTYPE = torch.bfloat16
WARMUP, ROUNDS = 5, 25
TOL = 2e-2


@triton.jit
def band_mask(b, h, q_idx, kv_idx):
    d = q_idx - kv_idx
    return (d < 1024) & (d > -1024)


@triton.jit
def prefix_lm_mask(b, h, q_idx, kv_idx):
    return (kv_idx < 1024) | (q_idx >= kv_idx)


def _register_flydsl_twins():
    import flydsl.expr as fx

    def band_fly(b, h, q_idx, kv_idx, seqlen_info, aux):
        d = q_idx - kv_idx
        return (d < fx.Int32(1024)) & (d > fx.Int32(-1024))

    def prefix_fly(b, h, q_idx, kv_idx, seqlen_info, aux):
        return (kv_idx < fx.Int32(1024)) | (q_idx >= kv_idx)

    turbo.ops.dual_mod(band_mask, band_fly)
    turbo.ops.dual_mod(prefix_lm_mask, prefix_fly)


# (name, B, Hq, Hkv, S, torch keep fn, turbo mask)
DENSE = [
    ("causal_s4k", 4, 16, 2, 4096, lambda q, kv: q >= kv, "causal"),
    ("causal_s8k", 2, 16, 2, 8192, lambda q, kv: q >= kv, "causal"),
    ("window1k_s8k", 2, 16, 2, 8192, lambda q, kv: (q >= kv) & (q - kv <= 1023), "window"),
    ("band1k_s8k", 2, 16, 2, 8192, lambda q, kv: (q - kv).abs() < 1024, band_mask),
    ("prefix_lm_s8k", 2, 16, 2, 8192, lambda q, kv: (kv < 1024) | (q >= kv), prefix_lm_mask),
]
INKLING = {layer.name: layer for layer in inkling.INKLING_LAYERS}
ALL = [d[0] for d in DENSE] + list(INKLING)
QUICK = ["causal_s8k", "window1k_s8k", "band1k_s8k", "inkling_global_5doc", "inkling_small_local_5doc"]


def _mask(spec, S):
    if spec == "causal":
        return turbo.ops.create_block_mask(turbo.ops.causal_mask, None, None, S, S)
    if spec == "window":
        return turbo.ops.create_block_mask(turbo.ops.sliding_window_mask(1023), None, None, S, S)
    return turbo.ops.create_block_mask(spec, None, None, S, S)


def _pairs(keep, S):
    idx = torch.arange(S, device="cuda")
    return int(keep(idx[:, None], idx[None, :]).sum().item())


def _time(fn):
    for _ in range(WARMUP):
        fn()
    torch.cuda.synchronize()
    samples = []
    for _ in range(ROUNDS):
        start, end = torch.cuda.Event(enable_timing=True), torch.cuda.Event(enable_timing=True)
        start.record()
        fn()
        end.record()
        end.synchronize()
        samples.append(start.elapsed_time(end))
    return statistics.median(samples), statistics.pstdev(samples)


def _setup(name):
    """(run(backend) -> out, leaves, forward FLOPs)."""
    if name in INKLING:
        layer = INKLING[name]
        x = inkling.make_inputs(layer, dtype=DTYPE)
        leaves = (x.q, x.k, x.v, x.rel_logits)
        return (lambda backend: inkling.turbo_flex(layer, x, {"BACKEND": backend})), leaves, layer.flops()
    _, B, Hq, Hkv, S, keep, spec = next(d for d in DENSE if d[0] == name)
    D = 128
    gen = torch.Generator().manual_seed(0)
    q, k, v = (torch.randn(B, h, S, D, generator=gen).to("cuda", DTYPE).requires_grad_(True) for h in (Hq, Hkv, Hkv))
    mask = _mask(spec, S)

    def run(backend):
        return turbo.ops.flex_attention(q, k, v, block_mask=mask, enable_gqa=True, kernel_options={"BACKEND": backend})

    return run, (q, k, v), 4 * B * Hq * D * _pairs(keep, S)


def _rel_err(got, ref):
    return (got.float() - ref.float()).abs().max().item() / max(ref.float().abs().max().item(), 1.0)


def bench(name, triton_timing):
    run, leaves, flops = _setup(name)
    out_ref = run("TRITON")
    dout = torch.randn_like(out_ref)
    grads_ref = torch.autograd.grad(out_ref, leaves, dout)
    out = run("FLYDSL")
    grads = torch.autograd.grad(out, leaves, dout, retain_graph=True)
    errs = [_rel_err(out, out_ref)] + [_rel_err(g, r) for g, r in zip(grads, grads_ref)]
    ok = all(math.isfinite(e) and e <= TOL for e in errs)

    def times(backend, o):
        with torch.no_grad():
            fwd = _time(lambda: run(backend))
        bwd = _time(lambda: torch.autograd.grad(o, leaves, dout, retain_graph=True))
        return fwd, bwd

    (f_ms, f_sd), (b_ms, b_sd) = times("FLYDSL", out)
    row = {
        "label": name,
        "Check": "PASS" if ok else "FAIL",
        "Forward TFLOPS": flops / f_ms / 1e9,
        "Forward TFLOPS_stddev": flops / f_ms / 1e9 * f_sd / f_ms,
        "Backward TFLOPS": 2.5 * flops / b_ms / 1e9,
        "Backward TFLOPS_stddev": 2.5 * flops / b_ms / 1e9 * b_sd / b_ms,
        "Forward Time (ms)": f_ms,
        "Backward Time (ms)": b_ms,
        "Triton Forward Time (ms)": "",
        "Triton Backward Time (ms)": "",
        "out_err": errs[0],
        "dq_err": errs[1],
        "dk_err": errs[2],
        "dv_err": errs[3],
        "daux_err": errs[4] if len(errs) > 4 else "",
    }
    if triton_timing:
        (tf, _), (tb, _) = times("TRITON", run("TRITON"))
        row["Triton Forward Time (ms)"], row["Triton Backward Time (ms)"] = tf, tb
    return row


COLUMNS = ["label", "Check", "Forward TFLOPS", "Forward TFLOPS_stddev", "Backward TFLOPS", "Backward TFLOPS_stddev",
           "Forward Time (ms)", "Backward Time (ms)", "Triton Forward Time (ms)", "Triton Backward Time (ms)",
           "out_err", "dq_err", "dk_err", "dv_err", "daux_err"]


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--shapes", default="quick")
    ap.add_argument("--summary-csv", default=None)
    ap.add_argument("--triton-timing", action="store_true")
    args = ap.parse_args()
    names = ALL if args.shapes == "all" else QUICK if args.shapes == "quick" else args.shapes.split(",")
    _register_flydsl_twins()
    rows = []
    for name in names:
        try:
            row = bench(name, args.triton_timing)
        except Exception as e:  # noqa: BLE001 - a failing shape is recorded, not fatal
            row = {c: "" for c in COLUMNS}
            row.update(label=name, Check="FAIL")
            print(f"{name}: ERROR {type(e).__name__}: {e}", flush=True)
        rows.append(row)
        fmt = {k: (f"{v:.4g}" if isinstance(v, float) else v) for k, v in row.items()}
        print(" | ".join(f"{k}={fmt[k]}" for k in COLUMNS if fmt[k] != ""), flush=True)
        torch.cuda.empty_cache()
    passed = [r for r in rows if r["Check"] == "PASS"]
    if passed:
        g = lambda k: math.exp(sum(math.log(r[k]) for r in passed) / len(passed))  # noqa: E731
        print(f"GEOMEAN over {len(passed)}/{len(rows)} PASS: Forward TFLOPS {g('Forward TFLOPS'):.3f} | "
              f"Backward TFLOPS {g('Backward TFLOPS'):.3f}", flush=True)
    if args.summary_csv:
        with open(args.summary_csv, "w", newline="") as f:
            w = csv.DictWriter(f, fieldnames=COLUMNS)
            w.writeheader()
            w.writerows(rows)


if __name__ == "__main__":
    main()
