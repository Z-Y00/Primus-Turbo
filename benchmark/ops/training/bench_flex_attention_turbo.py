###############################################################################
# Copyright (c) 2026, Advanced Micro Devices, Inc. All rights reserved.
#
# See LICENSE for license information.
###############################################################################

"""Benchmark Primus-Turbo flex attention against PyTorch FlexAttention.

PyTorch runs ``torch.compile(flex_attention)`` over a ``torch`` BlockMask; Turbo runs
``turbo.ops.flex_attention`` with the equivalent ``@triton.jit`` mask/score mods. Both
see the same bf16 inputs. Reports forward and forward+backward time, TFLOP/s over the
unmasked pairs, and the max output difference between the two.

Cases:
  causal / window   built-in masks (Turbo's fast path, no block lists)
  band / prefix_lm  custom masks on the block-sparse path
  inkling_*         Inkling's relative-position bias over 8K packed tokens: PyTorch
                    (B=1 with a document mask and rel_logits captured by score_mod, as
                    Miles trains it) vs Turbo's flex_attention_varlen_rel_bias

Usage: python bench_flex_attention_turbo.py [--cases inkling] [--mode max-autotune-no-cudagraphs]
"""

import argparse
import statistics

import torch
import triton
from tabulate import tabulate
from torch.nn.attention import flex_attention as torch_flex

import primus_turbo.pytorch as turbo

DTYPE = torch.bfloat16
WARMUP, ROUNDS = 10, 30


@triton.jit
def band_mask(b, h, q_idx, kv_idx):
    d = q_idx - kv_idx
    return (d < 1024) & (d > -1024)


@triton.jit
def prefix_lm_mask(b, h, q_idx, kv_idx):
    return (kv_idx < 1024) | (q_idx >= kv_idx)


def median_ms(fn):
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
    return statistics.median(samples)


def time_fwd_bwd(attend, leaves):
    out = attend()
    dout = torch.randn_like(out)
    with torch.no_grad():
        fwd = median_ms(attend)
    fwd_bwd = median_ms(lambda: torch.autograd.grad(attend(), leaves, dout))
    return out.detach(), fwd, fwd_bwd


def dense_cases():
    """(name, B, Hq, Hkv, S, torch mask_mod, turbo mask_mod)."""
    return [
        ("causal_s4k", 4, 16, 2, 4096, lambda b, h, q, kv: q >= kv, turbo.ops.causal_mask),
        ("causal_s8k", 2, 16, 2, 8192, lambda b, h, q, kv: q >= kv, turbo.ops.causal_mask),
        (
            "window1k_s8k",
            2,
            16,
            2,
            8192,
            lambda b, h, q, kv: (q >= kv) & (q - kv <= 1023),
            turbo.ops.sliding_window_mask(1023),
        ),
        ("band1k_s8k", 2, 16, 2, 8192, lambda b, h, q, kv: (q - kv).abs() < 1024, band_mask),
        ("prefix_lm_s8k", 2, 16, 2, 8192, lambda b, h, q, kv: (kv < 1024) | (q >= kv), prefix_lm_mask),
    ]


def bench_dense(name, B, Hq, Hkv, S, torch_mask, turbo_mask, compiled):
    D = 128
    gen = torch.Generator().manual_seed(0)
    q, k, v = (
        torch.randn(B, h, S, D, generator=gen).to("cuda", DTYPE).requires_grad_(True) for h in (Hq, Hkv, Hkv)
    )
    t_mask = torch_flex.create_block_mask(torch_mask, None, None, S, S, device="cuda")
    o_mask = turbo.ops.create_block_mask(turbo_mask, None, None, S, S)
    t_out, t_fwd, t_fb = time_fwd_bwd(
        lambda: compiled(q, k, v, block_mask=t_mask, enable_gqa=True), (q, k, v)
    )
    o_out, o_fwd, o_fb = time_fwd_bwd(
        lambda: turbo.ops.flex_attention(q, k, v, block_mask=o_mask, enable_gqa=True), (q, k, v)
    )
    flops = 4 * B * Hq * D * S * S * (1.0 - t_mask.sparsity() / 100.0)
    return name, flops, (t_fwd, t_fb), (o_fwd, o_fb), (t_out.float() - o_out.float()).abs().max().item()


# Inkling per-rank attention (TP=4): global layers (Hq/Hkv 16/2, extent 1024, no window)
# and local layers (16/4, extent = window = 512), 8K packed tokens.
INKLING = [
    ("inkling_global_1doc", 2, 1024, None, (8192,)),
    ("inkling_global_5doc", 2, 1024, None, (3072, 2048, 1536, 1024, 512)),
    ("inkling_local_1doc", 4, 512, 512, (8192,)),
    ("inkling_local_5doc", 4, 512, 512, (3072, 2048, 1536, 1024, 512)),
]


def bench_inkling(name, Hkv, RE, window, seqlens, compiled):
    Hq, D, T = 16, 128, sum(seqlens)
    gen = torch.Generator().manual_seed(0)
    q, k, v = (
        torch.randn(T, h, D, generator=gen).to("cuda", DTYPE).requires_grad_(True) for h in (Hq, Hkv, Hkv)
    )
    rel = (torch.randn(T, Hq, RE, generator=gen) * 0.25).cuda().requires_grad_(True)
    cu = torch.tensor((0,) + seqlens, device="cuda").cumsum(0).to(torch.int32)
    seg = torch.repeat_interleave(
        torch.arange(len(seqlens), device="cuda"), torch.tensor(seqlens, device="cuda")
    )
    rel_t = (
        rel.detach().permute(1, 0, 2).contiguous().requires_grad_(True)
    )  # [H, T, RE], as Miles lays it out

    def score_mod(score, b, h, q_idx, kv_idx):
        rd = q_idx - kv_idx
        bias = rel_t[h, q_idx, torch.clamp(rd, 0, RE - 1)]
        return torch.where((rd >= 0) & (rd < RE), score + bias.to(score.dtype), score)

    def mask_mod(b, h, q_idx, kv_idx):
        keep = (q_idx >= kv_idx) & (seg[q_idx] == seg[kv_idx])
        return keep if window is None else keep & (q_idx - kv_idx <= window - 1)

    t_mask = torch_flex.create_block_mask(mask_mod, None, None, T, T, device="cuda")
    qt, kt, vt = (t.permute(1, 0, 2).unsqueeze(0) for t in (q, k, v))
    t_out, t_fwd, t_fb = time_fwd_bwd(
        lambda: (
            compiled(qt, kt, vt, score_mod=score_mod, block_mask=t_mask, scale=1.0 / D, enable_gqa=True)
            .squeeze(0)
            .permute(1, 0, 2)
        ),
        (q, k, v, rel_t),
    )
    o_out, o_fwd, o_fb = time_fwd_bwd(
        lambda: turbo.ops.flex_attention_varlen_rel_bias(
            q, k, v, rel, cu, max(seqlens), scale=1.0 / D, window_left=None if window is None else window - 1
        ),
        (q, k, v, rel),
    )
    pairs = sum(
        L * (L + 1) // 2
        if window is None
        else min(window, L) * (min(window, L) + 1) // 2 + (L - min(window, L)) * window
        for L in seqlens
    )
    flops = 4 * Hq * D * pairs
    return name, flops, (t_fwd, t_fb), (o_fwd, o_fb), (t_out.float() - o_out.float()).abs().max().item()


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--cases", default="", help="substring filter on case names")
    parser.add_argument("--mode", default="default", help="torch.compile mode for PyTorch FlexAttention")
    args = parser.parse_args()
    compiled = torch.compile(
        torch_flex.flex_attention, dynamic=False, mode=None if args.mode == "default" else args.mode
    )

    rows = []
    jobs = [(c[0], bench_dense, c) for c in dense_cases()] + [(c[0], bench_inkling, c) for c in INKLING]
    for name, fn, case in jobs:
        if args.cases not in name:
            continue
        name, flops, (t_fwd, t_fb), (o_fwd, o_fb), diff = fn(*case, compiled)
        rows.append(
            [
                name,
                f"{t_fwd:.3f}",
                f"{o_fwd:.3f}",
                f"{t_fwd / o_fwd:.2f}x",
                f"{t_fb:.3f}",
                f"{o_fb:.3f}",
                f"{t_fb / o_fb:.2f}x",
                f"{flops / o_fwd / 1e9:.0f}",
                f"{3.5 * flops / o_fb / 1e9:.0f}",
                f"{diff:.3g}",
            ]
        )
        print(rows[-1], flush=True)
        torch._dynamo.reset()
        torch.cuda.empty_cache()
    print(f"\n{torch.cuda.get_device_name(0)}, torch {torch.__version__}, PyTorch compile mode={args.mode}")
    headers = [
        "case",
        "torch fwd ms",
        "turbo fwd ms",
        "fwd x",
        "torch f+b ms",
        "turbo f+b ms",
        "f+b x",
        "turbo fwd TF/s",
        "turbo f+b TF/s",
        "max |diff|",
    ]
    print(tabulate(rows, headers=headers, tablefmt="github"))


if __name__ == "__main__":
    main()
