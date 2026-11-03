###############################################################################
# Copyright (c) 2026, Advanced Micro Devices, Inc. All rights reserved.
#
# See LICENSE for license information.
###############################################################################

"""KV block range for a query block, the counterpart of FA4's ``block_info.BlockInfo``."""

from dataclasses import dataclass

import flydsl.expr as fx

from primus_turbo.flydsl.flex_attention.seqlen_info import SeqlenInfo


def _max(a, b):
    return (a > b).select(a, b)


def _min(a, b):
    return (a < b).select(a, b)


def _ceil_div(a, b: int):
    return (a + fx.Int32(b - 1)) // fx.Int32(b)


@dataclass
class BlockInfo:
    """Static tile sizes and mask kind. ``is_causal``: keys up to the (bottom-right
    aligned) diagonal. ``is_local``: runtime ``window_left`` / ``window_right``, where a
    negative bound means unbounded on that side; causal with a left window is passed as
    local with ``window_right = 0``."""

    tile_m: int
    tile_n: int
    is_causal: bool
    is_local: bool

    def get_n_block_min_max(self, seqlen: SeqlenInfo, m_block, window_left, window_right):
        """``[n_block_min, n_block_max)``: the KV blocks a query block can see."""
        n_block_max = _ceil_div(seqlen.seqlen_k, self.tile_n)
        n_block_min = fx.Int32(0)
        if self.is_causal or self.is_local:
            m_start = m_block * fx.Int32(self.tile_m)
            m_end = _min(m_start + fx.Int32(self.tile_m), seqlen.seqlen_q)
            zero = fx.Int32(0)
            if self.is_causal:
                last_key = m_end - fx.Int32(1) + seqlen.offset
                n_block_max = _min(n_block_max, _ceil_div(_max(last_key + fx.Int32(1), zero), self.tile_n))
            else:
                last_key = m_end - fx.Int32(1) + seqlen.offset + window_right
                bounded_max = _min(n_block_max, _ceil_div(_max(last_key + fx.Int32(1), zero), self.tile_n))
                n_block_max = (window_right >= zero).select(bounded_max, n_block_max)
                first_key = m_start + seqlen.offset - window_left
                n_block_min = (window_left >= zero).select(_max(first_key, zero) // fx.Int32(self.tile_n), zero)
        return n_block_min, n_block_max
