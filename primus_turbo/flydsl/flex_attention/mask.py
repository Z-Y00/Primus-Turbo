###############################################################################
# Copyright (c) 2026, Advanced Micro Devices, Inc. All rights reserved.
#
# See LICENSE for license information.
###############################################################################

"""Per-element masking, the counterpart of FA4's ``mask.AttentionMask``."""

from dataclasses import dataclass
from typing import Callable, Optional, Tuple

import flydsl.expr as fx

from primus_turbo.flydsl.flex_attention.seqlen_info import SeqlenInfo


def _min(a, b):
    return (a < b).select(a, b)


@dataclass
class AttentionMask:
    """Which (query, key) score elements are kept. Causal and local are bottom-right
    aligned (``key - query <= seqlen_k - seqlen_q``), as in FA4; ``window_left`` /
    ``window_right`` are runtime and negative means unbounded.

    ``mask_mod(batch_idx, head_idx, q_idx, kv_idx, seqlen_info, aux_tensors) -> bool``
    is FA4's signature, with sequence-local indices. Indices past a sequence's end
    (tile padding) are clamped to its last position before the call, so a mod that
    indexes an aux tensor by them stays in bounds; those positions are masked anyway.
    """

    seqlen: SeqlenInfo
    is_causal: bool
    is_local: bool
    window_left: fx.Int32
    window_right: fx.Int32
    mask_mod: Optional[Callable] = None
    batch_idx: Optional[fx.Int32] = None
    head_idx: Optional[fx.Int32] = None
    aux_tensors: Tuple = ()

    def clamp_q(self, q_pos):
        return _min(q_pos, self.seqlen.seqlen_q - fx.Int32(1))

    def clamp_kv(self, kv_pos):
        return _min(kv_pos, self.seqlen.seqlen_k - fx.Int32(1))

    def keep(self, q_pos, kv_pos, mask_seqlen: bool = True):
        keep = kv_pos < self.seqlen.seqlen_k if mask_seqlen else (kv_pos == kv_pos)
        if self.is_causal or self.is_local:
            rel = kv_pos - q_pos - self.seqlen.offset  # 0 on the diagonal
            if self.is_causal:
                keep = keep & (rel <= fx.Int32(0))
            else:
                zero = fx.Int32(0)
                right_ok = (self.window_right < zero) | (rel <= self.window_right)
                left_ok = (self.window_left < zero) | (rel >= -self.window_left)
                keep = keep & right_ok & left_ok
        if self.mask_mod is not None:
            keep = keep & self.mask_mod(
                self.batch_idx, self.head_idx, self.clamp_q(q_pos), self.clamp_kv(kv_pos), self.seqlen, self.aux_tensors
            )
        return keep
