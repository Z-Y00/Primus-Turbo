"""Run a round's tests and benchmarks spread over several GPUs of one node.

    python par_run.py [--gpus 0,1,...] [--shapes quick|all|a,b] [--tests] [--triton-timing]
                      [--ref-repo /tmp/t5] [--out /tmp/par]

Jobs (pytest shards, then one job per shape) are queued and each runs with
HIP_VISIBLE_DEVICES set to one free GPU and its own HOME, so JIT caches do not race. A
shape's job runs the reference tree (if any) and then the candidate, with Triton timing,
back to back on the same GPU, so every comparison within a shape is on one device.
Benchmarks start after all test shards finish. Writes <out>/benchmark.csv (and
<out>/reference.csv) with a "gpu" note per shape in <out>/gpu_map.txt.
"""

import argparse
import csv
import os
import subprocess
import sys
import time

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
TEST_FILES = os.environ.get("TEST_FILES", "tests/pytorch/ops/test_flex_attention_flydsl.py,tests/pytorch/ops/test_flex_attention_flydsl_paged.py").split(",")


def shape_names(spec):
    src = open(os.path.join(HERE, "quick_test_bench.py")).read()
    ns = {}
    # Shape lists without importing torch here.
    for line in src.splitlines():
        if line.startswith("QUICK = "):
            ns["quick"] = eval(line.split("=", 1)[1])
    if spec == "quick":
        return ns["quick"]
    if spec == "all":
        out = subprocess.run([sys.executable, "-c", "import quick_test_bench as q; print(','.join(q.ALL))"],
                             cwd=HERE, capture_output=True, text=True, check=True)
        return out.stdout.strip().split(",")
    return spec.split(",")


def test_shards(repo, n):
    out = subprocess.run([sys.executable, "-m", "pytest", "--collect-only", "-q", "-p", "no:cacheprovider",
                          "--noconftest", *TEST_FILES], cwd=repo, capture_output=True, text=True)
    ids = [line for line in out.stdout.splitlines() if "::" in line]
    return [ids[i::n] for i in range(n) if ids[i::n]]


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--gpus", default="0,1,2,3,4,5,6,7")
    ap.add_argument("--shapes", default="quick")
    ap.add_argument("--tests", action="store_true")
    ap.add_argument("--triton-timing", action="store_true")
    ap.add_argument("--ref-repo", default=None, help="second source tree to benchmark the same shapes on")
    ap.add_argument("--out", default="/tmp/par")
    args = ap.parse_args()
    gpus = [int(g) for g in args.gpus.split(",")]
    repo = os.environ.get("TURBO_REPO", "/tmp/t")
    os.makedirs(args.out, exist_ok=True)
    rel = os.path.relpath(os.path.join(HERE, "quick_test_bench.py"), repo)

    jobs = []  # (name, cwd, argv, csv or None)
    if args.tests:
        for i, shard in enumerate(test_shards(repo, len(gpus))):
            jobs.append((f"tests{i}", repo, [sys.executable, "-m", "pytest", "-q", "-p", "no:cacheprovider",
                                             "--noconftest", "-W", "ignore", *shard], None))
    trees = ([("ref", args.ref_repo)] if args.ref_repo else []) + [("bench", repo)]
    for s in shape_names(args.shapes):
        steps = []
        for tag, tree in trees:
            out_csv = os.path.join(args.out, f"{tag}_{s}.csv")
            extra = " --triton-timing" if args.triton_timing and tag == "bench" else ""
            steps.append(f"echo '## {tag}'; PYTHONPATH={tree} TURBO_REPO={tree} {sys.executable} "
                         f"{os.path.join(tree, rel)} --shapes {s} --summary-csv {out_csv}{extra}")
        jobs.append((f"shape_{s}", repo, ["bash", "-c", "; ".join(steps)], None))

    free, running, done = list(gpus), {}, []
    t0 = time.time()
    n_tests = sum(1 for j in jobs if j[0].startswith("tests"))
    while jobs or running:
        # Benchmarks start only after every test shard: compiles on the host CPU would
        # otherwise leak into the timed launches.
        tests_left = any(n.startswith("tests") for n in running) or any(j[0].startswith("tests") for j in jobs)
        while jobs and free and (jobs[0][0].startswith("tests") or not tests_left):
            name, cwd, argv, out_csv = jobs.pop(0)
            gpu = free.pop(0)
            home = os.path.join(args.out, f"home_{name}")
            os.makedirs(home, exist_ok=True)
            env = dict(os.environ, HIP_VISIBLE_DEVICES=str(gpu), HOME=home, PYTHONPATH=cwd, TURBO_REPO=cwd,
                       TRITON_CACHE_DIR=os.path.join(home, ".triton"))
            log = open(os.path.join(args.out, f"{name}.log"), "w")
            running[name] = (subprocess.Popen(argv, cwd=cwd, env=env, stdout=log, stderr=subprocess.STDOUT), gpu, log)
            print(f"[{time.time() - t0:6.0f}s] start {name} on GPU {gpu}", flush=True)
            with open(os.path.join(args.out, "gpu_map.txt"), "a") as gm:
                gm.write(f"{name} GPU {gpu}\n")
        for name, (proc, gpu, log) in list(running.items()):
            if proc.poll() is not None:
                log.close()
                free.append(gpu)
                done.append((name, proc.returncode))
                del running[name]
                print(f"[{time.time() - t0:6.0f}s] done  {name} (exit {proc.returncode})", flush=True)
        time.sleep(1)

    print(f"all jobs finished in {time.time() - t0:.0f}s", flush=True)
    passed = failed = 0
    for name, rc in done:
        lines = open(os.path.join(args.out, f"{name}.log")).read().splitlines()
        keep = [ln for ln in lines if "passed" in ln or "failed" in ln or "error" in ln.lower() or "GEOMEAN" in ln]
        if name.startswith("tests"):
            for ln in lines:
                if " passed" in ln:
                    passed += int(ln.split(" passed")[0].split()[-1])
                if " failed" in ln:
                    failed += int(ln.split(" failed")[0].split()[-1])
        print(f"== {name} exit={rc}: " + " | ".join(keep[-3:]))
    if args.tests:
        print(f"TESTS: {passed} passed, {failed} failed")
    for tag, _ in trees:
        rows = []
        for s in shape_names(args.shapes):
            path = os.path.join(args.out, f"{tag}_{s}.csv")
            if os.path.exists(path):
                rows += list(csv.DictReader(open(path)))
            else:
                rows.append({"label": s, "Check": "FAIL"})
        merged = os.path.join(args.out, "benchmark.csv" if tag == "bench" else "reference.csv")
        cols = list(csv.DictReader(open(next(p for p in [os.path.join(args.out, f"{tag}_{s}.csv") for s in shape_names(args.shapes)] if os.path.exists(p)))).fieldnames)
        with open(merged, "w", newline="") as f:
            w = csv.DictWriter(f, fieldnames=cols)
            w.writeheader()
            w.writerows({c: r.get(c, "") for c in cols} for r in rows)
        print(f"{tag.upper()}_CSV_BEGIN")
        print(open(merged).read().rstrip())
        print(f"{tag.upper()}_CSV_END")


if __name__ == "__main__":
    main()
