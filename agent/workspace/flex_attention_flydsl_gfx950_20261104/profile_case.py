"""Run one campaign shape a few times for rocprofv3: python profile_case.py <shape> [fwd|bwd]."""

import os
import sys

import torch

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import quick_test_bench as q  # noqa: E402

name = sys.argv[1]
which = sys.argv[2] if len(sys.argv) > 2 else "fwd"
q._register_flydsl_twins()
run, leaves, _ = q._setup(name)
out = run("FLYDSL")
dout = torch.randn_like(out)
for _ in range(5):
    if which == "fwd":
        with torch.no_grad():
            run("FLYDSL")
    else:
        torch.autograd.grad(out, leaves, dout, retain_graph=True)
torch.cuda.synchronize()
print("done", name, which)
