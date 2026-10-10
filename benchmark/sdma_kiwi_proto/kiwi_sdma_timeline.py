"""Per-phase timeline of KIWI SDMA dispatches from a kiwi_sdma_trace.sh trace.

For each of the last --dispatches dispatches, times are microseconds from the
earliest prepare-kernel start across ranks. The proxy's hipMemcpyBatchAsync and
hipStreamWriteValue64 calls are matched to the dispatch whose send kernel they
follow. The receiver's wait kernel ends once every peer's flag, and therefore
its data, has landed, so wait_e - batch_first is the SDMA transfer phase.

Usage: python kiwi_sdma_timeline.py <trace-dir> [--dispatches N]
"""

import argparse
import csv
import glob
import os
import statistics as st
from collections import defaultdict

KERNELS = {
    "prepare": "prepare_kiwi_sdma",
    "barrier": "barrier<",
    "send": "send_kiwi_sdma",
    "wait": "wait_kiwi_sdma",
    "unpack": "unpack_kiwi_sdma",
}
EVENTS = [
    ("prep_e", "prepare kernel end"),
    ("bar_e", "barrier end"),
    ("send_s", "send kernel start"),
    ("batch_first", "first hipMemcpyBatchAsync"),
    ("send_e", "send kernel end"),
    ("batch_last_e", "last hipMemcpyBatchAsync returns"),
    ("flag_last", "last flag write issued"),
    ("wait_e", "all peers' data landed"),
    ("unpack_e", "unpack end"),
]


def load(trace_dir):
    kernels = defaultdict(lambda: defaultdict(list))
    for path in glob.glob(os.path.join(trace_dir, "*_kernel_trace.csv")):
        pid = os.path.basename(path).split("_")[0]
        for row in csv.DictReader(open(path)):
            for kind, name in KERNELS.items():
                if name in row["Kernel_Name"]:
                    kernels[pid][kind].append(
                        (int(row["Start_Timestamp"]), int(row["End_Timestamp"])))
    api = defaultdict(lambda: defaultdict(list))
    for path in glob.glob(os.path.join(trace_dir, "*_hip_api_trace.csv")):
        for row in csv.DictReader(open(path)):
            api[row["Process_Id"]][row["Function"]].append(
                (int(row["Start_Timestamp"]), int(row["End_Timestamp"])))
    return kernels, api


def dispatch_events(k, calls, i):
    prep, send = k["prepare"][i], k["send"][i]
    nxt = k["prepare"][i + 1][0] if i + 1 < len(k["prepare"]) else float("inf")
    barriers = [b for b in k["barrier"] if prep[1] <= b[0] <= send[0]]
    batches = [c for c in calls["hipMemcpyBatchAsync"] if send[0] <= c[0] < nxt]
    flags = [c for c in calls["hipStreamWriteValue64"] if send[0] <= c[0] < nxt]
    return {
        "prep_s": prep[0], "prep_e": prep[1],
        "bar_e": barriers[-1][1] if barriers else None,
        "send_s": send[0], "send_e": send[1],
        "batch_first": batches[0][0] if batches else None,
        "batch_last_e": batches[-1][1] if batches else None,
        "flag_last": flags[-1][1] if flags else None,
        "wait_e": k["wait"][i][1],
        "unpack_s": k["unpack"][i][0], "unpack_e": k["unpack"][i][1],
        "batch_calls": len(batches),
        "batch_api_us": sum(e - s for s, e in batches) / 1e3,
    }


def main():
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("trace_dir")
    parser.add_argument("--dispatches", type=int, default=5,
                        help="analyze the last N dispatches (the timed ones)")
    args = parser.parse_args()
    kernels, api = load(args.trace_dir)
    pids = sorted(kernels)
    if not pids:
        raise SystemExit(f"no KIWI kernels in {args.trace_dir}")
    count = min(len(kernels[p]["send"]) for p in pids)
    timed = range(max(0, count - args.dispatches), count)

    timeline = defaultdict(list)
    durations = defaultdict(list)
    for i in timed:
        per = {p: dispatch_events(kernels[p], api[p], i) for p in pids}
        t0 = min(e["prep_s"] for e in per.values())
        for key, _ in EVENTS:
            values = [(e[key] - t0) / 1e3 for e in per.values() if e[key] is not None]
            if values:
                timeline[key].append((st.median(values), max(values)))
        for e in per.values():
            durations["packing (send kernel)"].append((e["send_e"] - e["send_s"]) / 1e3)
            durations["unpack kernel"].append((e["unpack_e"] - e["unpack_s"]) / 1e3)
            if e["batch_first"] is not None:
                durations["transfer (first batch to landed)"].append(
                    (e["wait_e"] - e["batch_first"]) / 1e3)
            durations["hipMemcpyBatchAsync calls"].append(e["batch_calls"])
            durations["time inside hipMemcpyBatchAsync"].append(e["batch_api_us"])

    print(f"{len(pids)} ranks, dispatches {timed.start}..{timed.stop - 1}; "
          "us from the earliest prepare start (median / max over ranks)")
    for key, label in EVENTS:
        if timeline[key]:
            med = st.median(a for a, _ in timeline[key])
            worst = st.median(b for _, b in timeline[key])
            print(f"  {label:36s} {med:8.1f}  {worst:8.1f}")
    print("per rank and dispatch (median / min / max)")
    for label, values in durations.items():
        print(f"  {label:36s} {st.median(values):8.1f}  {min(values):8.1f}  {max(values):8.1f}")


if __name__ == "__main__":
    main()
