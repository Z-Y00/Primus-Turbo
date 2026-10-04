###############################################################################
# Copyright (c) 2026, Advanced Micro Devices, Inc. All rights reserved.
###############################################################################

"""Flash-attention backward statistics for the gfx1250 FlyDSL backward.

``lse2 = LSE * log2(e)`` (``+inf`` where the forward saw no key) and ``delta = rowsum(dO * O)``,
head-major ``[Hq, tokens]`` fp32 with a padded row pitch, as ``flash_attn_bwd_gfx1250`` reads
them. Tokens are numbered ``b * seq + s`` (one segment per batch for dense layouts, or one
packed segment for THD), which is also the forward's LSE row order.
"""

import torch
import triton
import triton.language as tl


@triton.jit
def _attn_bwd_prep_kernel(
    O,
    DO,
    LSE,
    LSE2,
    DELTA,
    n_tok,
    seq,
    o_sb,
    o_ss,
    do_sb,
    do_ss,
    pitch,
    HQ: tl.constexpr,
    D: tl.constexpr,
    BLOCK_T: tl.constexpr,
):
    h = tl.program_id(1)
    t = tl.program_id(0) * BLOCK_T + tl.arange(0, BLOCK_T)
    valid = t < n_tok
    b = (t // seq).to(tl.int64)
    s = (t % seq).to(tl.int64)
    d = tl.arange(0, D)
    o_off = b * o_sb + s * o_ss + h * D
    do_off = b * do_sb + s * do_ss + h * D
    o = tl.load(O + o_off[:, None] + d[None, :], mask=valid[:, None], other=0.0).to(tl.float32)
    do = tl.load(DO + do_off[:, None] + d[None, :], mask=valid[:, None], other=0.0).to(tl.float32)
    delta = tl.sum(o * do, axis=1)
    lse = tl.load(LSE + t.to(tl.int64) * HQ + h, mask=valid, other=0.0)
    lse2 = tl.where(lse == float("-inf"), float("inf"), lse * 1.4426950408889634)
    # The pad columns are read (and masked) by the kernel's rounded-up loads; keep them finite.
    lse2 = tl.where(valid, lse2, 0.0)
    out = h.to(tl.int64) * pitch + t
    tl.store(LSE2 + out, lse2, mask=t < pitch)
    tl.store(DELTA + out, delta, mask=t < pitch)


def attn_bwd_prep(out: torch.Tensor, dout: torch.Tensor, lse: torch.Tensor, seq: int):
    """``out`` / ``dout``: ``[batch, seq, Hq, D]``-indexable views (any batch/seq strides,
    contiguous ``(Hq, D)``); ``lse``: ``[batch * seq, Hq]`` fp32 natural log, contiguous.
    Returns ``(lse2, delta)`` as ``[Hq, batch * seq]`` views of padded buffers."""
    B, S, Hq, D = out.shape
    assert S == seq and dout.shape == out.shape
    for x in (out, dout):
        assert x.stride(3) == 1 and x.stride(2) == D, "heads and head_dim must be contiguous"
    n_tok = B * S
    pitch = (n_tok + 3) // 4 * 4 + 4
    lse2 = torch.empty(Hq, pitch, device=out.device, dtype=torch.float32)
    delta = torch.empty(Hq, pitch, device=out.device, dtype=torch.float32)
    block_t = max(16, min(128, 8192 // D))
    grid = (triton.cdiv(pitch, block_t), Hq)
    _attn_bwd_prep_kernel[grid](
        out,
        dout,
        lse.contiguous(),
        lse2,
        delta,
        n_tok,
        S,
        out.stride(0),
        out.stride(1),
        dout.stride(0),
        dout.stride(1),
        pitch,
        HQ=Hq,
        D=D,
        BLOCK_T=block_t,
    )
    return lse2[:, :n_tok], delta[:, :n_tok]
