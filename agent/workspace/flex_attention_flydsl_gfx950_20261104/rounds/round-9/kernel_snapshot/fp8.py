###############################################################################
# Copyright (c) 2026, Advanced Micro Devices, Inc. All rights reserved.
#
# See LICENSE for license information.
###############################################################################

"""FP8 inputs in the GPU's native format: FNUZ on gfx942, OCP on gfx950.

OCP -> FNUZ (gfx942) reinterprets the bits: the same code is exactly half the value in
FNUZ (one more exponent bias), so the factor of 2 goes into the descale and the result
is exact; OCP's -0 is FNUZ's NaN and becomes +0. FNUZ -> OCP (gfx950) cannot do the
same, because FNUZ's largest codes would double past OCP's range, so it converts by
value instead: exact except that FNUZ's smallest subnormal rounds. NaN / inf inputs are
not preserved.
"""

import torch

_OCP = {"fp8_e4m3": torch.float8_e4m3fn, "fp8_e5m2": torch.float8_e5m2}
_FNUZ = {"fp8_e4m3": torch.float8_e4m3fnuz, "fp8_e5m2": torch.float8_e5m2fnuz}


def _convert(t: torch.Tensor, dtype: str, to_ocp: bool):
    """``(tensor in the target format, factor)`` with ``value_in = factor * value_out``."""
    target = _OCP[dtype] if to_ocp else _FNUZ[dtype]
    if t.dtype == target:
        return t, 1.0
    source = _FNUZ[dtype] if to_ocp else _OCP[dtype]
    if t.dtype != source:
        raise TypeError(f"expected {_OCP[dtype]} or {_FNUZ[dtype]}, got {t.dtype}")
    if to_ocp:
        return t.to(torch.float32).to(target), 1.0
    bits = t.view(torch.uint8)
    return torch.where(bits == 0x80, torch.zeros_like(bits), bits).view(target), 2.0


def dequantize_fp8(q, k, v, descales, qhead_per_kvhead: int, cu_seqlens_q=None, cu_seqlens_k=None):
    """bf16 ``x * descale`` for q / k / v with ``[B, Hk]`` descales (ones where absent);
    dense ``[B, S, H, D]`` or varlen ``[T, H, D]`` with ``cu_seqlens``."""

    def scale(t, d, cu, rep):
        if d is None:
            return t.to(torch.bfloat16)
        d = d.float().repeat_interleave(rep, dim=1)  # [B, H]
        if cu is None:
            return (t.float() * d[:, None, :, None]).to(torch.bfloat16)
        batch_of_token = torch.repeat_interleave(
            torch.arange(cu.numel() - 1, device=t.device), (cu[1:] - cu[:-1]).long(), output_size=t.shape[0]
        )
        return (t.float() * d[batch_of_token][:, :, None]).to(torch.bfloat16)

    q_d, k_d, v_d = descales
    return (
        scale(q, q_d, cu_seqlens_q, qhead_per_kvhead),
        scale(k, k_d, cu_seqlens_k, 1),
        scale(v, v_d, cu_seqlens_k, 1),
    )


def to_native_fp8(q, k, v, descales, dtype: str, ocp: bool):
    """Convert q / k / v to the native format; returns them with ``[B, Hk]`` fp32
    descales (ones where absent) that include the conversion factors."""
    q, fq = _convert(q, dtype, ocp)
    k, fk = _convert(k, dtype, ocp)
    v, fv = _convert(v, dtype, ocp)
    batch_hk = None
    for d in descales:
        if d is not None:
            batch_hk = tuple(d.shape)
    if batch_hk is None:
        raise ValueError("pass q_descale / k_descale / v_descale (shape [batch, num_kv_heads]) for fp8")
    out = []
    for d, factor in zip(descales, (fq, fk, fv)):
        d = torch.ones(batch_hk, dtype=torch.float32, device=q.device) if d is None else d.float()
        out.append((d * factor).contiguous() if factor != 1.0 else d.contiguous())
    return q, k, v, tuple(out)
