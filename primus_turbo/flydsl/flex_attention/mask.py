###############################################################################
# Copyright (c) 2026, Advanced Micro Devices, Inc. All rights reserved.
#
# See LICENSE for license information.
###############################################################################

"""Per-element masking, the counterpart of FA4's ``mask.AttentionMask``."""

from dataclasses import dataclass

import flydsl.expr as fx

from primus_turbo.flydsl.flex_attention.seqlen_info import SeqlenInfo


@dataclass
class AttentionMask:
    """Which (query, key) score elements are kept. Causal and local are bottom-right
    aligned (``key - query <= seqlen_k - seqlen_q``), as in FA4; ``window_left`` /
    ``window_right`` are runtime and negative means unbounded."""

    seqlen: SeqlenInfo
    is_causal: bool
    is_local: bool
    window_left: fx.Int32
    window_right: fx.Int32

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
        return keep
