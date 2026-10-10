###############################################################################
# Copyright (c) 2026, Advanced Micro Devices, Inc. All rights reserved.
#
# See LICENSE for license information.
###############################################################################

"""End-to-end distributed MoE benchmark for selectable EP transports.

The timed region contains dispatch, token permutation, grouped FC1, SwiGLU,
grouped FC2, token unpermutation, and combine. ``training`` mode additionally
runs the complete autograd backward.
"""

import argparse
import math
import os
import tempfile
import time

import torch
import torch.distributed as dist
import torch.multiprocessing as mp


def _inputs(rank, args):
    experts_per_rank = args.num_experts // args.num_processes
    generator = torch.Generator(device="cuda").manual_seed(args.seed + rank)
    x = torch.randn(
        args.num_tokens,
        args.hidden,
        generator=generator,
        device="cuda",
        dtype=torch.bfloat16,
    )
    w1 = torch.randn(
        experts_per_rank,
        2 * args.intermediate,
        args.hidden,
        generator=generator,
        device="cuda",
        dtype=torch.bfloat16,
    )
    w1.mul_(2.0 / math.sqrt(args.hidden))
    w2 = torch.randn(
        experts_per_rank,
        args.hidden,
        args.intermediate,
        generator=generator,
        device="cuda",
        dtype=torch.bfloat16,
    )
    w2.mul_(2.0 / math.sqrt(args.intermediate))
    logits = torch.randn(
        args.num_tokens,
        args.num_experts,
        generator=generator,
        device="cuda",
        dtype=torch.float32,
    )
    topk_weights, topk_idx = torch.topk(logits.softmax(-1), args.topk, dim=-1)
    gate = torch.zeros_like(logits).scatter_(1, topk_idx, topk_weights)
    return x, w1, w2, topk_idx.to(torch.int64), gate


def _run(rank: int, args, store_path: str) -> None:
    os.environ["PRIMUS_TURBO_MOE_DISPATCH_COMBINE_BACKEND"] = args.backend
    os.environ["PRIMUS_TURBO_EP_FORCE_CURRENT_STREAM"] = "1"
    if args.backend == "KIWI_SDMA":
        if os.environ.get("KIWI_SDMA_PROXY_CPU") is not None:
            os.environ["KIWI_SDMA_PROXY_CPU"] = str(
                int(os.environ["KIWI_SDMA_PROXY_CPU"]) + rank
            )
        for name in ("ROC_P2P_SDMA_SIZE", "GPU_FORCE_BLIT_COPY_SIZE"):
            value = os.environ.get(name, "")
            if not value.isdigit() or int(value) > 1024:
                raise RuntimeError(f"{args.backend} requires {name} <= 1024 (KB) before launch")

    torch.cuda.set_device(rank)
    dist.init_process_group(
        "nccl",
        rank=rank,
        world_size=args.num_processes,
        store=dist.FileStore(store_path, args.num_processes),
    )

    # Import only after selecting the backend; backend resolution is process-global.
    import torch.nn.functional as F

    from primus_turbo.pytorch.modules import DeepEPTokenDispatcher
    from primus_turbo.pytorch.ops import grouped_gemm

    x, w1, w2, topk_idx, gate = _inputs(rank, args)
    dispatcher = DeepEPTokenDispatcher(
        num_experts=args.num_experts,
        router_topk=args.topk,
        ep_group=dist.group.WORLD,
        permute_fusion=True,
        deepep_num_use_cu=args.num_sms,
        deepep_async_finish=False,
        deepep_allocate_on_comm_stream=False,
    )

    # Communication stages; everything else is local compute.
    comm_stages = ("dispatch", "combine")

    def moe_forward(x_arg, w1_arg, w2_arg, gate_arg, stage_events=None):
        # stage_events maps stage name -> list of (start, end) CUDA events
        # recorded on the current stream, so stages are timed on the GPU
        # without adding synchronization.
        def stage(name, function):
            if stage_events is None:
                return function()
            start_event = torch.cuda.Event(enable_timing=True)
            end_event = torch.cuda.Event(enable_timing=True)
            start_event.record()
            result = function()
            end_event.record()
            stage_events.setdefault(name, []).append((start_event, end_event))
            return result

        hidden, probs_in = stage(
            "route", lambda: dispatcher._pre_dispatch(x_arg, gate_arg, None, topk_idx)
        )
        tokens, token_probs = stage("dispatch", lambda: dispatcher._exec_dispatch(hidden, probs_in))
        dispatched, tokens_per_expert, probs = stage(
            "permute", lambda: dispatcher._post_dispatch(tokens, token_probs)
        )
        if args.stages == "dispatch":
            return dispatched
        if args.stages != "dispatch,combine":
            group_lens = tokens_per_expert.to(device=x_arg.device, dtype=torch.int64)
            fc1 = stage(
                "fc1",
                lambda: grouped_gemm(dispatched, w1_arg, group_lens, trans_b=True),
            )
            gate_part, up_part = fc1.chunk(2, dim=-1)
            activated = stage(
                "activation",
                lambda: (F.silu(gate_part) * up_part * probs.unsqueeze(-1)).to(x_arg.dtype),
            )
            dispatched = stage(
                "fc2",
                lambda: grouped_gemm(activated, w2_arg, group_lens, trans_b=True),
            )
        unpermuted = stage("unpermute", lambda: dispatcher._pre_combine(dispatched))
        combined = stage("combine", lambda: dispatcher._exec_combine(unpermuted))
        return dispatcher._post_combine(combined)

    grad_out = torch.randn_like(x)

    def iteration():
        if args.mode == "forward":
            with torch.no_grad():
                return moe_forward(x, w1, w2, gate)
        x_grad = x.detach().requires_grad_(True)
        w1_grad = w1.detach().requires_grad_(True)
        w2_grad = w2.detach().requires_grad_(True)
        gate_grad = gate.detach().requires_grad_(True)
        output = moe_forward(x_grad, w1_grad, w2_grad, gate_grad)
        torch.autograd.grad(
            output,
            (x_grad, w1_grad, w2_grad, gate_grad),
            grad_out,
        )
        return output

    output = None
    for _ in range(args.warmup):
        output = iteration()
    torch.cuda.synchronize()
    dist.barrier()

    start = time.perf_counter()
    for _ in range(args.iterations):
        output = iteration()
    torch.cuda.synchronize()
    elapsed_ms = (time.perf_counter() - start) * 1e3 / args.iterations

    latency = torch.tensor(elapsed_ms, dtype=torch.float64, device="cuda")
    dist.reduce(latency, dst=0, op=dist.ReduceOp.MAX)
    assert output is not None
    checksum = output.float().sum()
    dist.reduce(checksum, dst=0)
    if rank == 0:
        global_tokens = args.num_tokens * args.num_processes
        print(
            f"MOE backend={args.backend} mode={args.mode} EP={args.num_processes} "
            f"M={args.num_tokens} H={args.hidden} I={args.intermediate} "
            f"E={args.num_experts} topk={args.topk}: {latency.item():.3f} ms, "
            f"{global_tokens / (latency.item() * 1e-3):.1f} tokens/s, "
            f"checksum={checksum.item():.7e}",
            flush=True,
        )

    if args.breakdown:
        # Warm iterations timed per stage with stream events. "idle" is the
        # part of the iteration no stage covers: the GPU waiting on the host.
        stage_events = {}
        dist.barrier()
        torch.cuda.synchronize()
        start = time.perf_counter()
        with torch.no_grad():
            for _ in range(args.iterations):
                moe_forward(x, w1, w2, gate, stage_events)
        torch.cuda.synchronize()
        iteration_ms = (time.perf_counter() - start) * 1e3 / args.iterations
        names = [name for name in ("route", "dispatch", "permute", "fc1", "activation",
                                   "fc2", "unpermute", "combine") if name in stage_events]
        per_stage = [
            sum(s.elapsed_time(e) for s, e in stage_events[name]) / len(stage_events[name])
            for name in names
        ]
        comm = sum(t for name, t in zip(names, per_stage) if name in comm_stages)
        compute = sum(t for name, t in zip(names, per_stage) if name not in comm_stages)
        values = torch.tensor(
            per_stage + [comm, compute, iteration_ms - comm - compute, iteration_ms],
            dtype=torch.float64,
            device="cuda",
        )
        dist.reduce(values, dst=0, op=dist.ReduceOp.MAX)
        if rank == 0:
            v = values.tolist()
            print(
                f"MOE breakdown backend={args.backend} "
                + " ".join(f"{n}={t:.3f}" for n, t in zip(names, v))
                + f" | comm={v[-4]:.3f} compute={v[-3]:.3f} idle={v[-2]:.3f} "
                f"iteration={v[-1]:.3f} ms (max over ranks)",
                flush=True,
            )

    dist.barrier()
    dist.destroy_process_group()


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="End-to-end distributed MoE benchmark")
    parser.add_argument("--backend", choices=("TURBO", "DEEP_EP", "KIWI_SDMA"), required=True)
    parser.add_argument("--mode", choices=("forward", "training"), default="forward")
    parser.add_argument("--num-processes", type=int, choices=(2, 4, 8), default=8)
    parser.add_argument("--num-tokens", type=int, default=4096)
    parser.add_argument("--hidden", type=int, default=7168)
    parser.add_argument("--intermediate", type=int, default=2048)
    parser.add_argument("--num-experts", type=int, default=256)
    parser.add_argument("--topk", type=int, default=8)
    parser.add_argument("--num-sms", type=int, default=80)
    parser.add_argument("--warmup", type=int, default=3)
    parser.add_argument("--iterations", type=int, default=10)
    parser.add_argument("--seed", type=int, default=1234)
    parser.add_argument("--breakdown", action="store_true")
    parser.add_argument(
        "--stages",
        choices=("all", "dispatch", "dispatch,combine"),
        default="all",
        help="Run only a prefix of the layer (forward mode) to isolate transport issues.",
    )
    options = parser.parse_args()
    if options.num_experts % options.num_processes:
        parser.error("--num-experts must be divisible by --num-processes")
    with tempfile.NamedTemporaryFile() as store:
        mp.spawn(_run, args=(options, store.name), nprocs=options.num_processes)
