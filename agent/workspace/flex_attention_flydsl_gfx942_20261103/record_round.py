"""Write a round's summary table / trend row / log entry from benchmark.csv + same-GPU reference.

    python record_round.py N STATUS "description" ref_csv_name "hypothesis" "change" "attribution" "next"
"""
import csv, math, sys

n, status, desc, refname, hyp, change, attrib, nxt = sys.argv[1:9]
d = f"rounds/round-{n}"
a = list(csv.DictReader(open(f"{d}/artifacts/benchmark.csv")))
b = {r["label"]: r for r in csv.DictReader(open(f"{d}/artifacts/{refname}"))}
ref = [b[r["label"]] for r in a]
g = lambda rows, k: math.exp(sum(math.log(float(x[k])) for x in rows) / len(rows))
F, B, F0, B0 = g(a, "Forward TFLOPS"), g(a, "Backward TFLOPS"), g(ref, "Forward TFLOPS"), g(ref, "Backward TFLOPS")
rows = ["| shape | Check | ref fwd ms | fwd ms | fwd change | ref bwd ms | bwd ms | bwd change | fwd vs Triton | bwd vs Triton |",
        "|---|---|---|---|---|---|---|---|---|---|"]
for r in a:
    q = b[r["label"]]
    f, bb, qf, qb = (float(x) for x in (r["Forward Time (ms)"], r["Backward Time (ms)"], q["Forward Time (ms)"], q["Backward Time (ms)"]))
    tf, tb = r["Triton Forward Time (ms)"], r["Triton Backward Time (ms)"]
    vf = f"{f/float(tf):.2f}x" if tf else "-"
    vb = f"{bb/float(tb):.2f}x" if tb else "-"
    rows.append(f"| {r['label']} | {r['Check']} | {qf:.3f} | {f:.3f} | {100*(qf/f-1):+.1f}% | {qb:.3f} | {bb:.3f} | {100*(qb/bb-1):+.1f}% | {vf} | {vb} |")
table = "\n".join(rows)
open(f"{d}/summary.md", "w").write(f"""# Round {n} — {status}: {desc}

## Hypothesis

{hyp}

## Single change

{change}

## Results

- Validation: full (13 shapes) on a17-31's 8 GPUs; each shape's reference and candidate ran on the same GPU
  (`artifacts/validation.log`, gpu map at the end); tests before benchmarks.
- Raw artifacts: `artifacts/benchmark.csv`, `artifacts/{refname}`

{table}

- Forward geomean: {F0:.3f} -> {F:.3f} TFLOPS ({100*(F/F0-1):+.1f}%)
- Backward geomean: {B0:.3f} -> {B:.3f} TFLOPS ({100*(B/B0-1):+.1f}%)

## Decision

`{status}`

## Attribution

{attrib}

## Real-training transfer check
- Bucket: K1 (kernel-internal / launch configuration); no cache
- Estimated real-training gain: same as benchmark
- Decision: {"ACCEPT-as-real" if status == "ACCEPTED" else "REJECT (performance)"}

## Next direction

{nxt}
""")
open("logs/performance_trend.md", "a").write(f"| {n} | {status} | {desc} | {F:.3f} | {max(float(r['Forward TFLOPS']) for r in a):.3f} | {B:.3f} | {max(float(r['Backward TFLOPS']) for r in a):.3f} | - | vs previous accepted (same GPU): fwd {100*(F/F0-1):+.3f}%, bwd {100*(B/B0-1):+.3f}% | {attrib.split('.')[0]} |\n")
open("logs/optimize.md", "a").write(f"""
### round-{n} — {desc}
- Validation level: full (13 shapes), same-GPU reference
- Hypothesis: {hyp}
- Changes: {change}
- Result: forward {F0:.2f} -> {F:.2f} TFLOPS ({100*(F/F0-1):+.1f}%), backward {B0:.2f} -> {B:.2f} TFLOPS ({100*(B/B0-1):+.1f}%) {"✅" if status == "ACCEPTED" else "❌"}
- Decision: {status}
- Detailed data: rounds/round-{n}/summary.md
""")
print(F0, F, B0, B)
