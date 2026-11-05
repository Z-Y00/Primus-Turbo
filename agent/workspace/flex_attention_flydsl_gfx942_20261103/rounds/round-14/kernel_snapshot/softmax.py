###############################################################################
# Copyright (c) 2026, Advanced Micro Devices, Inc. All rights reserved.
#
# See LICENSE for license information.
###############################################################################

"""Online softmax, the counterpart of FA4's ``softmax.Softmax``.

Each lane owns one query row (the MFMA32 accumulator column). A KV tile's scores for
that row are split between the lane and its partner ``lane ^ 32``, so row reductions
are in-lane plus one ``shuffle_xor(32)``. Scores arrive in the log2 domain.
"""

import math

import flydsl.expr as fx

LOG2E = 1.4426950408889634
LN2 = math.log(2.0)
# Masked scores get a finite floor so exp2 stays finite under fast math; a row with no
# kept key at all is detected by its running max staying at the floor.
NEG_BIG = -1.0e30


def _f32(x):
    return fx.Float32(x)


def _max(a, b):
    return (a > b).select(a, b)


def _row_reduce(values, op):
    # Pairwise, so the dependency chain is log2(n) deep rather than n.
    vals = list(values)
    while len(vals) > 1:
        vals = [op(vals[i], vals[i + 1]) for i in range(0, len(vals) - 1, 2)] + vals[len(vals) - len(vals) % 2:]
    acc = vals[0]
    return op(acc, _f32(fx.gpu.shuffle_xor(acc, 32, 64)))


class Softmax:
    """Running row max ``m`` (log2 domain) and row sum ``l`` for this lane's query row."""

    @staticmethod
    def initial_state():
        return [_f32(NEG_BIG), _f32(0.0)]

    @staticmethod
    def online_softmax(row_max, row_sum, scores, keep):
        """Fold one tile in. ``scores`` / ``keep``: this lane's log2-domain scores and keep
        flags (``keep=None``: every score is kept). Returns ``(probs, new_max, new_sum,
        rescale)``; the caller scales O by ``rescale`` before accumulating ``probs @ V``."""
        if keep is None:
            masked = list(scores)
        else:
            masked = [k.select(s, _f32(NEG_BIG)) for s, k in zip(scores, keep)]
        tile_max = _row_reduce(masked, _max)
        new_max = _max(row_max, tile_max)
        rescale = fx.math.exp2(row_max - new_max)
        if keep is None:
            probs = [fx.math.exp2(s - new_max) for s in masked]
        else:
            probs = [k.select(fx.math.exp2(s - new_max), _f32(0.0)) for s, k in zip(masked, keep)]
        tile_sum = _row_reduce(probs, lambda a, b: a + b)
        return probs, new_max, row_sum * rescale + tile_sum, rescale

    @staticmethod
    def finalize(row_max, row_sum, sink_log2=None):
        """``(output scale, lse)`` with the LSE in natural log.

        ``sink_log2`` (a learnable sink logit times log2(e)) adds one more softmax term
        with no value vector, as in FA4: it joins the denominator and the LSE but not O.
        An empty row then gives O = 0 and LSE = the sink; without a sink, O = 0 and
        LSE = -inf.
        """
        if sink_log2 is None:
            has_keys = row_sum > _f32(0.0)
            scale = has_keys.select(_f32(1.0) / row_sum, _f32(0.0))
            lse = has_keys.select((row_max + fx.math.log2(row_sum)) * _f32(LN2), _f32(float("-inf")))
            return scale, lse
        new_max = _max(row_max, sink_log2)
        rescale = fx.math.exp2(row_max - new_max)
        total = row_sum * rescale + fx.math.exp2(sink_log2 - new_max)
        return rescale / total, (new_max + fx.math.log2(total)) * _f32(LN2)
