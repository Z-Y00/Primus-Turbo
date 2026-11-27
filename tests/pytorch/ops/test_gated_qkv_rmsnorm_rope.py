###############################################################################
# Copyright (c) 2026, Advanced Micro Devices, Inc. All rights reserved.
#
# See LICENSE for license information.
###############################################################################

import math

import pytest
import torch

from primus_turbo.pytorch.ops import dit_qk_norm_rope_cos_sin, fused_gated_qkv_rmsnorm_rope

requires_gpu = pytest.mark.skipif(not torch.cuda.is_available(), reason="needs a GPU")
EPS = 1e-5


def _freqs(S, D, dev, base=500000.0):
    inv = 1.0 / (base ** (torch.arange(0, D, 2, device=dev, dtype=torch.float32) / D))
    f = torch.outer(torch.arange(S, device=dev, dtype=torch.float32), inv)
    return torch.cat([f, f], dim=-1)[:, None, None, :]


def _reference(qkv, freqs, H, rope):
    """Megatron's split of the gated packed QKV, a weightless fp32 RMSNorm per head and the unfused RoPE."""
    S, B, G, W = qkv.shape
    D = W // (2 * H + 2)
    q, gate, k, v = torch.split(qkv, [H * D, H * D, D, D], dim=3)
    q = q.reshape(S, B, G * H, D)

    def rms(x):
        x32 = x.float()
        return (x32 * torch.rsqrt(x32.pow(2).mean(-1, keepdim=True) + EPS)).to(x.dtype)

    def rot(t):
        cos, sin = torch.cos(freqs).to(t.dtype), torch.sin(freqs).to(t.dtype)
        t1, t2 = torch.chunk(t, 2, dim=-1)
        return t * cos + torch.cat((-t2, t1), dim=-1) * sin

    q, k = rms(q), rms(k)
    if rope:
        q, k = rot(q), rot(k)
    return q, gate, k, v


def _ulp_ratio(got, want):
    # two bf16 ulps of the head's max |want|: RoPE moves a 1-ulp difference of the normalized value onto smaller outputs
    tol = torch.exp2(torch.floor(torch.log2(want.float().abs().amax(-1, keepdim=True).clamp_min(2.0))) - 6)
    return float(((got.detach().float() - want.detach().float()).abs() / tol).max())


def _snr(got, want):
    want = want.detach().float()
    noise = float((got.detach().float() - want).norm())
    return math.inf if noise == 0 else -20 * math.log10(noise / float(want.norm()))


@requires_gpu
@pytest.mark.parametrize(
    "S,B,G,H,D,rope",
    [
        (512, 1, 16, 8, 64, True),
        (256, 2, 16, 8, 64, True),
        (512, 1, 16, 8, 64, False),
        (256, 1, 6, 4, 128, True),  # two groups per program
        (128, 3, 1, 2, 64, True),  # one group, one per program
        (128, 1, 5, 1, 32, False),
    ],
)
def test_matches_unfused(S, B, G, H, D, rope):
    torch.manual_seed(0)
    dev = torch.device("cuda")
    freqs = _freqs(S, D, dev)
    cos, sin = dit_qk_norm_rope_cos_sin(freqs, torch.bfloat16)
    x = (torch.randn(S, B, G, (2 * H + 2) * D, device=dev) * 3).bfloat16()
    xr, xf = x.clone().requires_grad_(), x.clone().requires_grad_()
    ref = _reference(xr, freqs, H, rope)
    out = fused_gated_qkv_rmsnorm_rope(xf, cos if rope else None, sin if rope else None, H, EPS, rope)
    assert [tuple(o.shape) for o in out] == [tuple(r.shape) for r in ref]
    for name, o, r in zip(("q", "gate", "k", "v"), out, ref):
        if name in ("gate", "v"):
            assert torch.equal(o, r)
            continue
        mismatch = float((o != r).float().mean())
        assert mismatch <= 1e-4, f"{name}: {mismatch:.2e} of the elements differ"
        assert _ulp_ratio(o, r) <= 1.0, name
        assert _snr(o, r) >= 60, name
    grads = [torch.randn_like(r.float()).bfloat16() for r in ref]
    torch.autograd.backward(ref, grads)
    torch.autograd.backward(out, grads)
    assert _snr(xf.grad, xr.grad) >= 45


@requires_gpu
def test_partial_and_strided_grads():
    torch.manual_seed(1)
    dev = torch.device("cuda")
    S, B, G, H, D = 256, 2, 8, 8, 64
    freqs = _freqs(S, D, dev)
    cos, sin = dit_qk_norm_rope_cos_sin(freqs, torch.bfloat16)
    x = torch.randn(S, B, G, (2 * H + 2) * D, device=dev).bfloat16()
    xr, xf = x.clone().requires_grad_(), x.clone().requires_grad_()
    qr, gr, kr, _ = _reference(xr, freqs, H, True)
    qf, gf, kf, _ = fused_gated_qkv_rmsnorm_rope(xf, cos, sin, H, EPS)
    # v unused; q's gradient arrives through a transpose (non-contiguous)
    w = torch.randn(B, S, G * H, D, device=dev).bfloat16().transpose(0, 1)
    ((qr.float() * w.float()).sum() + gr.float().sum() + kr.float().pow(2).sum()).backward()
    ((qf.float() * w.float()).sum() + gf.float().sum() + kf.float().pow(2).sum()).backward()
    assert _snr(xf.grad, xr.grad) >= 45
    v_cols = xf.grad[..., (2 * H + 1) * D :]
    assert torch.count_nonzero(v_cols) == 0


@requires_gpu
def test_rejects_unsupported():
    dev = torch.device("cuda")
    x = torch.randn(8, 1, 2, 18 * 64, device=dev).bfloat16()
    cos = torch.zeros(8, 64, device=dev, dtype=torch.bfloat16)
    with pytest.raises(ValueError, match="heads per group"):
        fused_gated_qkv_rmsnorm_rope(
            torch.randn(8, 1, 2, 14 * 48, device=dev).bfloat16(), None, None, 6, EPS, False
        )
    with pytest.raises(ValueError, match="cos must be"):
        fused_gated_qkv_rmsnorm_rope(x, cos[:4], cos, 8, EPS)
    with pytest.raises(ValueError, match="bfloat16"):
        fused_gated_qkv_rmsnorm_rope(x.float(), cos, cos, 8, EPS)
