###############################################################################
# Copyright (c) 2026, Advanced Micro Devices, Inc. All rights reserved.
#
# See LICENSE for license information.
###############################################################################

"""Launch and validation helpers for the gated packed QKV weightless Q / K RMSNorm + RoPE (Triton)."""

from __future__ import annotations

import torch

from primus_turbo.triton.rope.gated_qkv_rmsnorm_rope_kernel import (
    gated_qkv_rmsnorm_rope_bwd_kernel,
    gated_qkv_rmsnorm_rope_fwd_kernel,
)

# query groups of one token per program (the largest that divides G) and warps per program
_GROUPS_PER_PROG = (4, 2, 1)
_NUM_WARPS = 2


def _pow2(n: int) -> bool:
    return n > 0 and n & (n - 1) == 0


def _groups_per_prog(G: int) -> int:
    return next(gp for gp in _GROUPS_PER_PROG if G % gp == 0)


def gated_qkv_rmsnorm_rope_shape_error(qkv, cos, sin, heads_per_group: int, rope: bool) -> str | None:
    """Return why this input is unsupported, or ``None`` when the kernels accept it."""
    if qkv.ndim != 4:
        return f"qkv must be [S,B,G,(2H+2)*D], got {tuple(qkv.shape)}"
    if qkv.dtype != torch.bfloat16 or not qkv.is_contiguous() or not qkv.is_cuda:
        return f"qkv must be contiguous CUDA bfloat16, got dtype={qkv.dtype} contiguous={qkv.is_contiguous()}"
    H = int(heads_per_group)
    S, _, _, W = qkv.shape
    if H <= 0 or W % (2 * H + 2):
        return f"packed width {W} is not (2 * {H} + 2) * head_dim"
    D = W // (2 * H + 2)
    if not (_pow2(H) and _pow2(D) and D >= 16):
        return f"heads per group ({H}) and head_dim ({D}) must be powers of 2, head_dim >= 16"
    if rope:
        for name, t in (("cos", cos), ("sin", sin)):
            if t is None or tuple(t.shape) != (S, D):
                return f"{name} must be [{S},{D}], got {None if t is None else tuple(t.shape)}"
            if t.dtype != torch.bfloat16 or not t.is_contiguous() or t.device != qkv.device:
                return f"{name} must be contiguous bfloat16 on qkv's device"
    return None


def gated_qkv_rmsnorm_rope_fwd_impl(qkv, cos, sin, heads_per_group: int, eps: float, rope: bool):
    """``(q [S,B,G*H,D], k [S,B,G,D], q_rstd, k_rstd)``; the gate and v stay views of ``qkv``."""
    S, B, G, W = qkv.shape
    H = int(heads_per_group)
    D = W // (2 * H + 2)
    gp = _groups_per_prog(G)
    q = torch.empty(S, B, G * H, D, device=qkv.device, dtype=qkv.dtype)
    k = torch.empty(S, B, G, D, device=qkv.device, dtype=qkv.dtype)
    q_rstd = torch.empty(S * B * G * H, device=qkv.device, dtype=torch.float32)
    k_rstd = torch.empty(S * B * G, device=qkv.device, dtype=torch.float32)
    cos_t, sin_t = (cos, sin) if rope else (qkv, qkv)
    with torch.cuda.device(qkv.device):
        gated_qkv_rmsnorm_rope_fwd_kernel[(S * B * G // gp,)](
            qkv, cos_t, sin_t, q, k, q_rstd, k_rstd, B, float(eps),
            G=G, H=H, D=D, HALF=D // 2, ROT=bool(rope), GP=gp, num_warps=_NUM_WARPS,
        )  # fmt: skip
    return q, k, q_rstd, k_rstd


def _rows_ready(t, shape, like):
    if t is None:
        return torch.zeros(shape, device=like.device, dtype=like.dtype)
    # the kernel reads the heads of one (s, b) as one contiguous run
    return t if t.stride(-1) == 1 and t[0, 0].is_contiguous() else t.contiguous()


def gated_qkv_rmsnorm_rope_bwd_impl(
    dq, dgate, dk, dv, qkv, cos, sin, q_rstd, k_rstd, heads_per_group: int, rope
):
    """d(qkv) in the packed layout, from the q / gate / k / v gradients (any of them None)."""
    S, B, G, W = qkv.shape
    H = int(heads_per_group)
    D = W // (2 * H + 2)
    gp = _groups_per_prog(G)
    dq = _rows_ready(dq, (S, B, G * H, D), qkv)
    dgate = _rows_ready(dgate, (S, B, G, H * D), qkv)
    dk = _rows_ready(dk, (S, B, G, D), qkv)
    dv = _rows_ready(dv, (S, B, G, D), qkv)
    dqkv = torch.empty_like(qkv)
    cos_t, sin_t = (cos, sin) if rope else (qkv, qkv)
    with torch.cuda.device(qkv.device):
        gated_qkv_rmsnorm_rope_bwd_kernel[(S * B * G // gp,)](
            qkv, dq, dk, dgate, dv, cos_t, sin_t, q_rstd, k_rstd, dqkv, B,
            dq.stride(0), dq.stride(1), dk.stride(0), dk.stride(1),
            dgate.stride(0), dgate.stride(1), dv.stride(0), dv.stride(1),
            G=G, H=H, D=D, HALF=D // 2, ROT=bool(rope), GP=gp, num_warps=_NUM_WARPS,
        )  # fmt: skip
    return dqkv
