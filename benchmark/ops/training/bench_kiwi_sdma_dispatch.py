###############################################################################
# Copyright (c) 2026, Advanced Micro Devices, Inc. All rights reserved.
#
# See LICENSE for license information.
###############################################################################

"""Focused BF16/FP16 benchmark for the KIWI batched-SDMA dispatch path."""

import argparse
import math
import os
import tempfile
import time

import torch
import torch.distributed as dist
import torch.multiprocessing as mp

import primus_turbo.pytorch as pt


def _timed_ms(function, iterations: int) -> float:
    dist.barrier()
    torch.cuda.synchronize()
    start = time.perf_counter()
    for _ in range(iterations):
        function()
    torch.cuda.synchronize()
    elapsed = torch.tensor((time.perf_counter() - start) * 1e3 / iterations,
                           dtype=torch.float64, device="cuda")
    dist.all_reduce(elapsed, op=dist.ReduceOp.MAX)
    return elapsed.item()


def _overlap(rank, args, buffer, dispatch_x, handle, config) -> None:
    """How much dispatch time hides behind independent GEMMs.

    KIWI: dispatch with return_recv_hook, run the GEMMs on the same stream,
    then call the hook. TURBO: its CU dispatch on a side stream concurrently
    with the same GEMMs. hidden = dispatch + gemm - overlapped.
    """
    a = torch.randn(args.gemm_m, args.gemm_k, dtype=torch.bfloat16, device="cuda")
    b = torch.randn(args.gemm_k, args.gemm_n, dtype=torch.bfloat16, device="cuda")

    def gemm():
        for _ in range(args.overlap_gemm):
            torch.matmul(a, b)

    def kiwi_dispatch():
        buffer.dispatch_sdma(dispatch_x, handle=handle, config=config)

    def kiwi_overlapped():
        *_, hook = buffer.dispatch_sdma(
            dispatch_x, handle=handle, config=config, return_recv_hook=True
        )
        gemm()
        hook()

    side = torch.cuda.Stream()

    def turbo_dispatch():
        buffer.dispatch(dispatch_x, handle=handle, config=config)

    def turbo_overlapped():
        main = torch.cuda.current_stream()
        side.wait_stream(main)
        with torch.cuda.stream(side):
            turbo_dispatch()
        gemm()
        main.wait_stream(side)

    rows = []
    for _ in range(args.warmup):
        gemm()
    gemm_ms = _timed_ms(gemm, args.iterations)
    for name, alone, overlapped in (
        ("KIWI_SDMA (hook)", kiwi_dispatch, kiwi_overlapped),
        ("TURBO (side stream)", turbo_dispatch, turbo_overlapped),
    ):
        for function in (alone, overlapped):
            for _ in range(args.warmup):
                function()
        alone_ms = _timed_ms(alone, args.iterations)
        overlapped_ms = _timed_ms(overlapped, args.iterations)
        hidden = alone_ms + gemm_ms - overlapped_ms
        rows.append((name, alone_ms, overlapped_ms, hidden))
    if rank == 0:
        print(f"overlap: gemm alone {gemm_ms:.3f} ms "
              f"({args.overlap_gemm} x [{args.gemm_m}x{args.gemm_k}]x[{args.gemm_k}x{args.gemm_n}])")
        for name, alone_ms, overlapped_ms, hidden in rows:
            print(f"overlap: {name}: dispatch alone {alone_ms:.3f} ms, dispatch+gemm "
                  f"{overlapped_ms:.3f} ms, hidden {hidden:.3f} ms "
                  f"({100 * hidden / alone_ms:.0f}% of dispatch)", flush=True)


def _run(rank: int, args, store_path: str) -> None:
    # Run TURBO's dispatch on whichever stream is current, so the overlap
    # benchmark can place it on a side stream.
    os.environ["PRIMUS_TURBO_EP_FORCE_CURRENT_STREAM"] = "1"
    if "KIWI_SDMA_PROXY_CPU" in os.environ:
        os.environ["KIWI_SDMA_PROXY_CPU"] = str(
            int(os.environ["KIWI_SDMA_PROXY_CPU"]) + rank
        )
    torch.cuda.set_device(rank)
    dist.init_process_group(
        "nccl",
        rank=rank,
        world_size=args.num_processes,
        store=dist.FileStore(store_path, args.num_processes),
    )
    dtype = torch.bfloat16 if args.dtype == "bf16" else torch.float16
    config = pt.deep_ep.Config(args.num_sms, 4, 64, 4, 64)
    Buffer = pt.deep_ep.Buffer
    nvl_bytes = Buffer.get_kiwi_sdma_nvl_buffer_size_hint(
        args.num_processes,
        args.hidden * 2,
        args.num_tokens,
        num_topk=args.num_processes,
        configs=(config, Buffer.get_combine_config(args.num_processes)),
    )
    buffer = Buffer(dist.group.WORLD, nvl_bytes, explicitly_destroy=True)

    x = torch.full(
        (args.num_tokens, args.hidden), rank + 1, dtype=dtype, device="cuda"
    )
    scale_bytes = 0
    if args.dtype == "fp8":
        x = x.float().to(torch.float8_e4m3fn)
        scales = torch.ones(
            (args.num_tokens, args.hidden // 128),
            dtype=torch.float32,
            device="cuda",
        )
        dispatch_x = (x, scales)
        scale_bytes = scales.size(1) * scales.element_size()
    else:
        dispatch_x = x
    experts_per_rank = 2
    num_experts = experts_per_rank * args.num_processes
    topk_idx = (
        torch.arange(args.num_processes, dtype=torch.int64, device="cuda")
        .mul(experts_per_rank)
        .repeat(args.num_tokens, 1)
    )
    weights = torch.ones_like(topk_idx, dtype=torch.float32)
    per_rank, _, per_expert, mask, _ = buffer.get_dispatch_layout(
        topk_idx, num_experts
    )
    recv_x, _, _, _, handle, _ = buffer.dispatch_sdma(
        dispatch_x,
        num_tokens_per_rank=per_rank,
        is_token_in_rank=mask,
        num_tokens_per_expert=per_expert,
        topk_idx=topk_idx,
        topk_weights=weights,
        config=config,
    )
    torch.cuda.synchronize()

    for _ in range(args.warmup):
        buffer.dispatch_sdma(dispatch_x, handle=handle, config=config)
    torch.cuda.synchronize()
    start = time.perf_counter()
    for _ in range(args.iterations):
        buffer.dispatch_sdma(dispatch_x, handle=handle, config=config)
    torch.cuda.synchronize()

    latency_us = (time.perf_counter() - start) * 1e6 / args.iterations
    latency = torch.tensor([latency_us], dtype=torch.float64, device="cuda")
    dist.reduce(latency, dst=0, op=dist.ReduceOp.MAX)
    if rank == 0:
        hidden_bytes = args.hidden * x.element_size()
        metadata_bytes = 4 + args.num_processes * 12
        record_bytes = (
            (metadata_bytes + 15) // 16 * 16 + (hidden_bytes + 15) // 16 * 16 + scale_bytes
        )
        chunk_bytes = int(os.environ.get("PRIMUS_TURBO_KIWI_SDMA_CHUNK_BYTES", str(1 << 20)))
        num_channels = args.num_sms // 2
        if chunk_bytes > 0:
            rows_per_chunk = max(1, chunk_bytes // record_bytes)
            copies_per_rank = (
                (args.num_processes - 1)
                * num_channels
                * math.ceil(math.ceil(args.num_tokens / num_channels) / rows_per_chunk)
            )
        else:
            rows_per_chunk = args.num_tokens
            copies_per_rank = args.num_processes - 1
        payload = (
            args.num_tokens
            * args.hidden
            * (x.element_size() + scale_bytes / args.hidden)
            * (args.num_processes - 1)
        )
        print(
            f"KIWI SDMA {args.dtype.upper()} EP={args.num_processes} "
            f"M={args.num_tokens} H={args.hidden}: {latency.item():.2f} us, "
            f"{payload / (latency.item() * 1e3):.2f} GB/s cross-rank payload, "
            f"chunk_bytes={chunk_bytes or 'per-destination'} rows_per_copy={rows_per_chunk} "
            f"copies_per_rank={copies_per_rank} proxy_cpu="
            f"{os.environ.get('KIWI_SDMA_PROXY_CPU', 'unbound')}"
        )
    if args.overlap_gemm > 0:
        _overlap(rank, args, buffer, dispatch_x, handle, config)
    buffer.destroy()
    dist.destroy_process_group()


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--num-processes", type=int, choices=(2, 4, 8), default=8)
    parser.add_argument("--num-tokens", type=int, default=4096)
    parser.add_argument("--hidden", type=int, choices=(2048, 7168), default=7168)
    parser.add_argument("--dtype", choices=("bf16", "fp16", "fp8"), default="bf16")
    parser.add_argument("--num-sms", type=int, default=20)
    parser.add_argument("--warmup", type=int, default=10)
    parser.add_argument("--iterations", type=int, default=50)
    parser.add_argument("--overlap-gemm", type=int, default=0,
                        help="GEMMs per iteration for the overlap measurement (0: skip)")
    parser.add_argument("--gemm-m", type=int, default=8192)
    parser.add_argument("--gemm-k", type=int, default=7168)
    parser.add_argument("--gemm-n", type=int, default=4096)
    opts = parser.parse_args()
    for name in ("ROC_P2P_SDMA_SIZE", "GPU_FORCE_BLIT_COPY_SIZE"):
        assert os.environ.get(name, "").isdigit() and int(os.environ[name]) <= 1024, name
    with tempfile.NamedTemporaryFile() as store:
        mp.spawn(_run, args=(opts, store.name), nprocs=opts.num_processes)
