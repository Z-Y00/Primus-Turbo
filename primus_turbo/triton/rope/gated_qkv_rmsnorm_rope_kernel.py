###############################################################################
# Copyright (c) 2026, Advanced Micro Devices, Inc. All rights reserved.
#
# See LICENSE for license information.
###############################################################################

"""Triton kernels of ``fused_gated_qkv_rmsnorm_rope``: weightless per-head Q / K RMSNorm and rotate-half RoPE on
a gated packed QKV ``[S, B, G, (2H + 2) * D]`` (per query group ``q: H x D | gate: H x D | k: D | v: D``).

Each program takes ``GP`` query groups of one token. Every value is rounded to bf16 where the unfused path
(split, ``round(x32 * rsqrt(mean(x32^2) + eps))``, ``round(round(n * cos) + round(rot(n) * sin))``) rounds it.
A head is handled as its two halves, so the rotation is a swap of halves.
"""

import triton
import triton.language as tl


@triton.jit
def _r(x):
    return x.to(tl.bfloat16).to(tl.float32)


@triton.jit
def _cos_sin(COS, SIN, s, j, D: tl.constexpr, HALF: tl.constexpr, ROT: tl.constexpr):
    if ROT:
        cos_lo = tl.load(COS + s * D + j).to(tl.float32)
        cos_hi = tl.load(COS + s * D + HALF + j).to(tl.float32)
        sin_lo = tl.load(SIN + s * D + j).to(tl.float32)
        sin_hi = tl.load(SIN + s * D + HALF + j).to(tl.float32)
    else:
        cos_lo = tl.zeros([HALF], tl.float32)
        cos_hi = cos_lo
        sin_lo = cos_lo
        sin_hi = cos_lo
    return cos_lo, cos_hi, sin_lo, sin_hi


@triton.jit
def _norm_rope_rows(src, dst, rdst, rows, j, cos_lo, cos_hi, sin_lo, sin_hi, eps,
                    D: tl.constexpr, HALF: tl.constexpr, ROT: tl.constexpr):  # fmt: skip
    lo = tl.load(src + rows[:, None] * D + j[None, :]).to(tl.float32)
    hi = tl.load(src + rows[:, None] * D + HALF + j[None, :]).to(tl.float32)
    r = 1.0 / tl.sqrt((tl.sum(lo * lo, axis=1) + tl.sum(hi * hi, axis=1)) / D + eps)
    nlo = _r(lo * r[:, None])
    nhi = _r(hi * r[:, None])
    if ROT:
        olo = _r(_r(nlo * cos_lo[None, :]) + _r(-nhi * sin_lo[None, :]))
        ohi = _r(_r(nhi * cos_hi[None, :]) + _r(nlo * sin_hi[None, :]))
    else:
        olo = nlo
        ohi = nhi
    tl.store(dst + rows[:, None] * D + j[None, :], olo.to(tl.bfloat16))
    tl.store(dst + rows[:, None] * D + HALF + j[None, :], ohi.to(tl.bfloat16))
    tl.store(rdst + rows, r)


@triton.jit
def _norm_rope_rows_bwd(gsrc, xsrc, dst, rsrc, rows, j, cos_lo, cos_hi, sin_lo, sin_hi,
                        D: tl.constexpr, HALF: tl.constexpr, ROT: tl.constexpr):  # fmt: skip
    glo = tl.load(gsrc + rows[:, None] * D + j[None, :]).to(tl.float32)
    ghi = tl.load(gsrc + rows[:, None] * D + HALF + j[None, :]).to(tl.float32)
    if ROT:
        # autograd of the rotate-half RoPE, rounded as its mul / add / cat steps are
        dlo = _r(_r(glo * cos_lo[None, :]) + _r(ghi * sin_hi[None, :]))
        dhi = _r(_r(ghi * cos_hi[None, :]) - _r(glo * sin_lo[None, :]))
    else:
        dlo = glo
        dhi = ghi
    lo = tl.load(xsrc + rows[:, None] * D + j[None, :]).to(tl.float32)
    hi = tl.load(xsrc + rows[:, None] * D + HALF + j[None, :]).to(tl.float32)
    r = tl.load(rsrc + rows)
    # d/dx of x * r with r = rsqrt(mean(x^2) + eps): r * dn - x * r^3 * mean(dn * x)
    c = (tl.sum(dlo * lo, axis=1) + tl.sum(dhi * hi, axis=1)) / D
    k3 = r * r * r * c
    tl.store(dst + rows[:, None] * D + j[None, :], (r[:, None] * dlo - lo * k3[:, None]).to(tl.bfloat16))
    tl.store(
        dst + rows[:, None] * D + HALF + j[None, :], (r[:, None] * dhi - hi * k3[:, None]).to(tl.bfloat16)
    )


@triton.jit
def gated_qkv_rmsnorm_rope_fwd_kernel(
    QKV, COS, SIN, QO, KO, QR, KR, B, eps,
    G: tl.constexpr, H: tl.constexpr, D: tl.constexpr, HALF: tl.constexpr, ROT: tl.constexpr, GP: tl.constexpr,
):  # fmt: skip
    pid = tl.program_id(0).to(tl.int64)  # (s, b, block of GP groups) flattened
    g0 = (pid % (G // GP)) * GP
    sb = pid // (G // GP)
    s = sb // B
    W: tl.constexpr = (2 * H + 2) * D
    j = tl.arange(0, HALF)
    h = tl.arange(0, H)
    one = tl.arange(0, 1)
    cos_lo, cos_hi, sin_lo, sin_hi = _cos_sin(COS, SIN, s, j, D, HALF, ROT)
    for gi in tl.static_range(GP):
        g = g0 + gi
        base = QKV + (sb * G + g) * W
        _norm_rope_rows(base, QO + (sb * G * H + g * H) * D, QR + sb * G * H + g * H, h, j,
                        cos_lo, cos_hi, sin_lo, sin_hi, eps, D, HALF, ROT)  # fmt: skip
        _norm_rope_rows(base + 2 * H * D, KO + (sb * G + g) * D, KR + sb * G + g, one, j,
                        cos_lo, cos_hi, sin_lo, sin_hi, eps, D, HALF, ROT)  # fmt: skip


@triton.jit
def gated_qkv_rmsnorm_rope_bwd_kernel(
    QKV, DQ, DK, DGATE, DV, COS, SIN, QR, KR, DQKV, B,
    sq_s, sq_b, sk_s, sk_b, sg_s, sg_b, sv_s, sv_b,
    G: tl.constexpr, H: tl.constexpr, D: tl.constexpr, HALF: tl.constexpr, ROT: tl.constexpr, GP: tl.constexpr,
):  # fmt: skip
    pid = tl.program_id(0).to(tl.int64)
    g0 = (pid % (G // GP)) * GP
    sb = pid // (G // GP)
    s = sb // B
    bb = sb % B
    W: tl.constexpr = (2 * H + 2) * D
    j = tl.arange(0, HALF)
    h = tl.arange(0, H)
    one = tl.arange(0, 1)
    hd = tl.arange(0, H * D)
    d = tl.arange(0, D)
    cos_lo, cos_hi, sin_lo, sin_hi = _cos_sin(COS, SIN, s, j, D, HALF, ROT)
    for gi in tl.static_range(GP):
        g = g0 + gi
        base = QKV + (sb * G + g) * W
        out = DQKV + (sb * G + g) * W
        _norm_rope_rows_bwd(DQ + s * sq_s + bb * sq_b + g * H * D, base, out, QR + sb * G * H + g * H, h, j,
                            cos_lo, cos_hi, sin_lo, sin_hi, D, HALF, ROT)  # fmt: skip
        _norm_rope_rows_bwd(DK + s * sk_s + bb * sk_b + g * D, base + 2 * H * D, out + 2 * H * D, KR + sb * G + g,
                            one, j, cos_lo, cos_hi, sin_lo, sin_hi, D, HALF, ROT)  # fmt: skip
        # the gate and v gradients pass through into the packed gradient
        tl.store(out + H * D + hd, tl.load(DGATE + s * sg_s + bb * sg_b + g * H * D + hd))
        tl.store(out + (2 * H + 1) * D + d, tl.load(DV + s * sv_s + bb * sv_b + g * D + d))
