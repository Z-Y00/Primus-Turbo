###############################################################################
# Copyright (c) 2026, Advanced Micro Devices, Inc. All rights reserved.
#
# See LICENSE for license information.
###############################################################################

"""Flex attention with the ``torch.nn.attention.flex_attention`` interface.

    out = flex_attention(query, key, value, score_mod=score_mod, block_mask=block_mask)

``query`` is ``[B, Hq, Sq, D]``, ``key``/``value`` ``[B, Hkv, Skv, D]`` (GQA needs
``enable_gqa=True``), as in PyTorch. ``flex_attention_varlen`` is the packed-sequence
sibling (``[total_tokens, H, D]`` plus ``cu_seqlens``), which PyTorch has no equivalent
for.

Differences from PyTorch, all because the mods are inlined into a Triton kernel rather
than traced:

* ``score_mod(score, b, h, q_idx, kv_idx)`` and ``mask_mod(b, h, q_idx, kv_idx)`` are
  ``@triton.jit`` functions (see ``flex_attention_masks`` / ``flex_attention_mods``).
* ``score_mod`` is not auto-differentiated: give its VJP as
  ``score_mod_bwd(dscore, score, b, h, q_idx, kv_idx)`` (``identity_score_mod_bwd`` for
  any additive mod).
* A tensor read by ``score_mod`` is passed explicitly in ``aux_tensors`` (appended to
  the ``score_mod`` arguments) and is read-only. To train it, also pass it as
  ``score_grad_target`` with a ``score_grad_hook``, which the backward calls once per
  tile of its dQ sweep to write the gradient.
* ``return_aux`` supports ``lse`` but not ``max_scores``.
"""

from dataclasses import dataclass, field
from typing import NamedTuple, Optional, Tuple

import torch

from primus_turbo.pytorch.kernels.flex_attention.flex_attention_block_mask_utils import (
    BlockPlan,
)
from primus_turbo.pytorch.kernels.flex_attention.flex_attention_impl import (
    flex_attention_backward_impl,
    flex_attention_forward_impl,
)
from primus_turbo.pytorch.ops.attention.flex_attention_masks import BlockMask
from primus_turbo.triton.flex_attention.flex_attention_utils import MAX_AUX_TENSORS

__all__ = ["AuxOutput", "AuxRequest", "flex_attention", "flex_attention_varlen"]


class AuxRequest(NamedTuple):
    """Which auxiliary outputs to return. Only ``lse`` is supported."""

    lse: bool = False
    max_scores: bool = False


class AuxOutput(NamedTuple):
    lse: Optional[torch.Tensor] = None
    max_scores: Optional[torch.Tensor] = None


_KERNEL_OPTIONS = ("num_splits",)


@dataclass
class _Config:
    """Everything the autograd function needs besides the differentiable tensors."""

    scale: float
    causal: bool
    window: Tuple[int, int]
    score_mod: object = None
    mask_mod: object = None
    score_mod_bwd: object = None
    block_plan: Optional[BlockPlan] = None
    num_splits: int = 1
    aux_tensors: list = field(default_factory=list)
    score_grad_hook: object = None
    cu_seqlens_q: Optional[torch.Tensor] = None
    cu_seqlens_k: Optional[torch.Tensor] = None
    max_seqlen_q: int = 0
    max_seqlen_k: int = 0

    @property
    def varlen(self) -> bool:
        return self.cu_seqlens_q is not None


class FlexAttentionFunc(torch.autograd.Function):
    """q/k/v arrive in the user layout (``[B, H, S, D]`` dense, ``[T, H, D]`` varlen); dense
    tensors are handed to the kernels as ``bshd`` views, so nothing is copied."""

    @staticmethod
    def forward(ctx, q, k, v, score_grad_target, cfg: _Config):
        ctx.set_materialize_grads(False)
        if cfg.varlen:
            total, heads, _ = q.shape
            out = torch.empty(total, heads, v.shape[-1], dtype=q.dtype, device=q.device)
            lse = torch.empty(heads, total, dtype=torch.float32, device=q.device)
            qk, kk, vk, ok = q, k, v, out
        else:
            batch, heads, seqlen_q, _ = q.shape
            out = torch.empty(batch, heads, seqlen_q, v.shape[-1], dtype=q.dtype, device=q.device)
            lse = torch.empty(batch, heads, seqlen_q, dtype=torch.float32, device=q.device)
            qk, kk, vk, ok = (t.transpose(1, 2) for t in (q, k, v, out))
        flex_attention_forward_impl(
            qk,
            kk,
            vk,
            ok,
            lse,
            scale=cfg.scale,
            causal=cfg.causal,
            window=cfg.window,
            cu_seqlens_q=cfg.cu_seqlens_q,
            cu_seqlens_k=cfg.cu_seqlens_k,
            max_seqlen_q=cfg.max_seqlen_q,
            max_seqlen_k=cfg.max_seqlen_k,
            score_mod=cfg.score_mod,
            mask_mod=cfg.mask_mod,
            block_plan=cfg.block_plan,
            num_splits=cfg.num_splits,
            aux_tensors=cfg.aux_tensors,
        )
        ctx.save_for_backward(q, k, v, out, lse)
        ctx.cfg = cfg
        ctx.score_grad_like = (
            None
            if score_grad_target is None
            else (score_grad_target.shape, score_grad_target.dtype, score_grad_target.device)
        )
        return out, lse

    @staticmethod
    def backward(ctx, dout, dlse):
        q, k, v, out, lse = ctx.saved_tensors
        cfg = ctx.cfg
        if dout is None:
            dout = torch.zeros_like(out)
        dout = dout.contiguous()
        dq, dk, dv = torch.zeros_like(q), torch.zeros_like(k), torch.zeros_like(v)
        # The hook's buffer is allocated here, not in the forward, so it is never held
        # across the gap between the passes; and only when its target wants a gradient.
        score_grad = None
        if ctx.score_grad_like is not None and ctx.needs_input_grad[3]:
            shape, dtype, device = ctx.score_grad_like
            score_grad = torch.zeros(shape, dtype=dtype, device=device)
        tensors = (dout, q, k, v, out, dq, dk, dv)
        if not cfg.varlen:
            tensors = tuple(t.transpose(1, 2) for t in tensors)
        flex_attention_backward_impl(
            *tensors[:5],
            lse,
            *tensors[5:],
            scale=cfg.scale,
            causal=cfg.causal,
            window=cfg.window,
            cu_seqlens_q=cfg.cu_seqlens_q,
            cu_seqlens_k=cfg.cu_seqlens_k,
            max_seqlen_q=cfg.max_seqlen_q,
            max_seqlen_k=cfg.max_seqlen_k,
            score_mod=cfg.score_mod,
            mask_mod=cfg.mask_mod,
            score_mod_bwd=cfg.score_mod_bwd,
            block_plan=cfg.block_plan,
            aux_tensors=cfg.aux_tensors,
            score_grad_hook=cfg.score_grad_hook if score_grad is not None else None,
            score_grad=score_grad,
            dlse=None if dlse is None else dlse.contiguous(),
        )
        return dq, dk, dv, score_grad, None


def _check_mods(q, k, v, score_mod, score_mod_bwd, aux_tensors, score_grad_hook, score_grad_target):
    if q.dtype not in (torch.float16, torch.bfloat16):
        raise ValueError(f"flex attention supports fp16 / bf16, got {q.dtype}")
    if not (q.dtype == k.dtype == v.dtype):
        raise ValueError("query, key and value must share a dtype")
    if score_mod_bwd is not None and score_mod is None:
        raise ValueError("score_mod_bwd was given without score_mod")
    needs_grad = torch.is_grad_enabled() and any(t.requires_grad for t in (q, k, v))
    if score_mod is not None and score_mod_bwd is None and needs_grad:
        raise ValueError(
            "score_mod needs score_mod_bwd for the backward: it is inlined into the Triton "
            "kernel, not traced, so give its VJP (identity_score_mod_bwd for an additive mod)"
        )
    if aux_tensors:
        if score_mod is None:
            raise ValueError("aux_tensors are only read by score_mod, but no score_mod was given")
        if len(aux_tensors) > MAX_AUX_TENSORS:
            raise ValueError(f"at most {MAX_AUX_TENSORS} aux_tensors are supported, got {len(aux_tensors)}")
        for i, t in enumerate(aux_tensors):
            if not isinstance(t, torch.Tensor) or t.device != q.device:
                raise ValueError(f"aux_tensors[{i}] must be a tensor on {q.device}")
            if not t.is_contiguous():
                raise ValueError(
                    f"aux_tensors[{i}] must be contiguous: score_mod indexes it as a flat pointer"
                )
            if t.requires_grad and torch.is_grad_enabled():
                raise ValueError(
                    f"aux_tensors[{i}] requires grad, but aux tensors are read-only in the kernel. "
                    "Pass it detached, and pass the tensor itself as score_grad_target with a "
                    "score_grad_hook to get its gradient."
                )
    if (score_grad_hook is None) != (score_grad_target is None):
        raise ValueError("score_grad_hook and score_grad_target must be given together")
    if score_grad_target is not None:
        if score_grad_target.device != q.device or not score_grad_target.is_contiguous():
            raise ValueError(f"score_grad_target must be a contiguous tensor on {q.device}")


def _resolve_options(kernel_options, return_lse, return_aux, block_plan, varlen):
    options = dict(kernel_options or {})
    unknown = set(options) - set(_KERNEL_OPTIONS)
    if unknown:
        raise ValueError(f"unsupported kernel_options {sorted(unknown)}; supported: {_KERNEL_OPTIONS}")
    num_splits = int(options.get("num_splits", 1))
    if num_splits < 1:
        raise ValueError(f"num_splits must be >= 1, got {num_splits}")
    if num_splits > 1 and (varlen or block_plan is not None):
        raise NotImplementedError(
            "num_splits > 1 is supported for dense attention without a block-sparse mask"
        )
    if return_aux is not None:
        if return_lse:
            raise ValueError("return_lse and return_aux cannot both be given; use return_aux")
        if return_aux.max_scores:
            raise NotImplementedError("return_aux=AuxRequest(max_scores=True) is not supported")
    return num_splits


def _mask_path(block_mask: Optional[BlockMask]):
    """(causal, window, mask_mod, block_plan) for the kernel."""
    if block_mask is None:
        return False, (-1, -1), None, None
    if block_mask._fast_path is not None:
        causal, left, right = block_mask._fast_path
        return causal, (left, right), None, None
    return False, (-1, -1), block_mask.mask_mod, block_mask.plan


def _finish(out, lse, return_lse, return_aux):
    if return_aux is not None:
        return out, AuxOutput(lse=lse if return_aux.lse else None)
    return (out, lse) if return_lse else out


def flex_attention(
    query: torch.Tensor,
    key: torch.Tensor,
    value: torch.Tensor,
    score_mod=None,
    block_mask: Optional[BlockMask] = None,
    scale: Optional[float] = None,
    enable_gqa: bool = False,
    return_lse: bool = False,
    kernel_options: Optional[dict] = None,
    *,
    return_aux: Optional[AuxRequest] = None,
    score_mod_bwd=None,
    aux_tensors: Optional[list] = None,
    score_grad_hook=None,
    score_grad_target: Optional[torch.Tensor] = None,
):
    """Attention over ``[B, H, S, D]`` tensors with an optional score_mod and block mask.

    Returns ``out`` ``[B, Hq, Sq, Dv]``; with ``return_aux``, ``(out, AuxOutput)`` whose
    ``lse`` is ``[B, Hq, Sq]`` (natural log, differentiable). ``kernel_options`` accepts
    ``num_splits`` (split the KV loop to fill the GPU for short-query / long-context
    shapes; dense masks only).
    """
    if query.dim() != 4 or key.dim() != 4 or value.dim() != 4:
        raise ValueError("flex_attention expects [B, H, S, D] query/key/value")
    batch, heads_q, seqlen_q, _ = query.shape
    heads_kv, seqlen_k = key.shape[1], key.shape[2]
    if key.shape[0] != batch or value.shape[:3] != key.shape[:3] or key.shape[-1] != query.shape[-1]:
        raise ValueError(
            f"incompatible shapes: query {tuple(query.shape)}, key {tuple(key.shape)}, value {tuple(value.shape)}"
        )
    if heads_q != heads_kv and not enable_gqa:
        raise ValueError(f"query has {heads_q} heads and key {heads_kv}; pass enable_gqa=True for GQA")
    if heads_q % heads_kv:
        raise ValueError(f"query heads {heads_q} must be a multiple of key heads {heads_kv}")
    if block_mask is not None:
        if block_mask.is_varlen:
            raise ValueError("this block mask was built for flex_attention_varlen")
        mb, mh, mq, mk = block_mask.shape
        if (mq, mk) != (seqlen_q, seqlen_k) or mb not in (1, batch) or mh not in (1, heads_q):
            raise ValueError(
                f"block mask shape {block_mask.shape} does not match "
                f"(B={batch}, H={heads_q}, Q_LEN={seqlen_q}, KV_LEN={seqlen_k})"
            )
    _check_mods(query, key, value, score_mod, score_mod_bwd, aux_tensors, score_grad_hook, score_grad_target)
    causal, window, mask_mod, block_plan = _mask_path(block_mask)
    num_splits = _resolve_options(kernel_options, return_lse, return_aux, block_plan, varlen=False)
    cfg = _Config(
        scale=query.shape[-1] ** -0.5 if scale is None else float(scale),
        causal=causal,
        window=window,
        score_mod=score_mod,
        mask_mod=mask_mod,
        score_mod_bwd=score_mod_bwd,
        block_plan=block_plan,
        num_splits=num_splits,
        aux_tensors=list(aux_tensors or ()),
        score_grad_hook=score_grad_hook,
    )
    out, lse = FlexAttentionFunc.apply(query, key, value, score_grad_target, cfg)
    return _finish(out, lse, return_lse, return_aux)


def flex_attention_varlen(
    query: torch.Tensor,
    key: torch.Tensor,
    value: torch.Tensor,
    cu_seqlens_q: torch.Tensor,
    cu_seqlens_k: torch.Tensor,
    max_seqlen_q: int,
    max_seqlen_k: int,
    score_mod=None,
    block_mask: Optional[BlockMask] = None,
    scale: Optional[float] = None,
    enable_gqa: bool = False,
    return_lse: bool = False,
    kernel_options: Optional[dict] = None,
    *,
    return_aux: Optional[AuxRequest] = None,
    score_mod_bwd=None,
    aux_tensors: Optional[list] = None,
    score_grad_hook=None,
    score_grad_target: Optional[torch.Tensor] = None,
):
    """Flex attention over packed sequences: ``[total_tokens, H, D]`` with int32
    ``cu_seqlens`` offsets. Sequences never attend each other.

    ``block_mask`` comes from :func:`create_block_mask_varlen`; mods see sequence-local
    ``q_idx`` / ``kv_idx`` and the sequence index as ``b``. With ``return_aux`` the
    ``lse`` is ``[Hq, total_q]``.
    """
    if query.dim() != 3 or key.dim() != 3 or value.dim() != 3:
        raise ValueError("flex_attention_varlen expects [total_tokens, H, D] query/key/value")
    if cu_seqlens_q.dtype != torch.int32 or cu_seqlens_k.dtype != torch.int32:
        raise ValueError("cu_seqlens must be int32")
    heads_q, heads_kv = query.shape[1], key.shape[1]
    if heads_q != heads_kv and not enable_gqa:
        raise ValueError(f"query has {heads_q} heads and key {heads_kv}; pass enable_gqa=True for GQA")
    if heads_q % heads_kv or key.shape[-1] != query.shape[-1] or value.shape[:2] != key.shape[:2]:
        raise ValueError(
            f"incompatible shapes: query {tuple(query.shape)}, key {tuple(key.shape)}, value {tuple(value.shape)}"
        )
    if block_mask is not None:
        if not block_mask.is_varlen:
            raise ValueError("flex_attention_varlen needs a block mask from create_block_mask_varlen")
        if block_mask.shape[1] not in (1, heads_q):
            raise ValueError(f"block mask has {block_mask.shape[1]} heads, query has {heads_q}")
    _check_mods(query, key, value, score_mod, score_mod_bwd, aux_tensors, score_grad_hook, score_grad_target)
    causal, window, mask_mod, block_plan = _mask_path(block_mask)
    num_splits = _resolve_options(kernel_options, return_lse, return_aux, block_plan, varlen=True)
    cfg = _Config(
        scale=query.shape[-1] ** -0.5 if scale is None else float(scale),
        causal=causal,
        window=window,
        score_mod=score_mod,
        mask_mod=mask_mod,
        score_mod_bwd=score_mod_bwd,
        block_plan=block_plan,
        num_splits=num_splits,
        aux_tensors=list(aux_tensors or ()),
        score_grad_hook=score_grad_hook,
        cu_seqlens_q=cu_seqlens_q,
        cu_seqlens_k=cu_seqlens_k,
        max_seqlen_q=int(max_seqlen_q),
        max_seqlen_k=int(max_seqlen_k),
    )
    out, lse = FlexAttentionFunc.apply(query, key, value, score_grad_target, cfg)
    return _finish(out, lse, return_lse, return_aux)
