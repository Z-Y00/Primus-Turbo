###############################################################################
# Copyright (c) 2026, Advanced Micro Devices, Inc. All rights reserved.
#
# See LICENSE for license information.
###############################################################################

"""Ready-made FlyDSL score / mask mods, with FA4's signatures:

    score_mod(score, batch_idx, head_idx, q_idx, kv_idx, seqlen_info, aux_tensors) -> score
    score_mod_bwd(dscore, score, batch_idx, head_idx, q_idx, kv_idx, seqlen_info, aux_tensors) -> dscore
    mask_mod(batch_idx, head_idx, q_idx, kv_idx, seqlen_info, aux_tensors) -> bool

They are plain Python functions traced into the kernel, one element at a time:
``score`` is an ``fx.Float32`` already multiplied by ``softmax_scale``, the indices are
``fx.Int32`` and sequence-local, and ``aux_tensors`` is a tuple of buffer tensors.
Because a mod is traced rather than AST-rewritten, branch with ``.select`` rather than
a Python ``if`` on runtime values.
"""

import functools
import math

import flydsl.expr as fx


def tanh(x):
    """``tanh`` from ``exp2``; ``math.tanh`` has no AMDGPU lowering (no ``ftanh`` libcall)."""
    t = fx.math.exp2(fx.math.absf(x) * fx.Float32(-2.0 * math.log2(math.e)))
    return fx.math.copysign((fx.Float32(1.0) - t) / (fx.Float32(1.0) + t), x)


def identity_score_mod_bwd(dscore, score, batch_idx, head_idx, q_idx, kv_idx, seqlen_info, aux_tensors):
    """VJP of any additive score_mod (``score + f(...)``)."""
    return dscore


@functools.lru_cache(maxsize=None)
def make_softcap_mods(softcap: float):
    """``(score_mod, score_mod_bwd)`` for ``cap * tanh(score / cap)``, as FA4 implements
    ``softcap``. Cached so one value maps to one function (and one compiled kernel)."""
    cap = float(softcap)
    inv = 1.0 / cap

    def softcap_score_mod(score, batch_idx, head_idx, q_idx, kv_idx, seqlen_info, aux_tensors):
        return fx.Float32(cap) * tanh(score * fx.Float32(inv))

    def softcap_score_mod_bwd(dscore, score, batch_idx, head_idx, q_idx, kv_idx, seqlen_info, aux_tensors):
        t = tanh(score * fx.Float32(inv))
        return dscore * (fx.Float32(1.0) - t * t)

    return softcap_score_mod, softcap_score_mod_bwd
