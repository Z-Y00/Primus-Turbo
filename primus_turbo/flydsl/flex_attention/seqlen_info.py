###############################################################################
# Copyright (c) 2026, Advanced Micro Devices, Inc. All rights reserved.
#
# See LICENSE for license information.
###############################################################################

"""Per-sequence offsets and lengths, the counterpart of FA4's ``seqlen_info.SeqlenInfoQK``."""

from dataclasses import dataclass

import flydsl.expr as fx


@dataclass
class SeqlenInfo:
    """Where this batch entry's queries / keys start in a packed (varlen) tensor, and how
    many there are. ``offset`` is ``seqlen_k - seqlen_q``: causal and local masks are
    bottom-right aligned, as in FA4."""

    offset_q: fx.Int32
    offset_k: fx.Int32
    seqlen_q: fx.Int32
    seqlen_k: fx.Int32

    @property
    def offset(self) -> fx.Int32:
        return self.seqlen_k - self.seqlen_q

    @staticmethod
    def create(batch, seqlen_q_static, seqlen_k_static, cu_seqlens_q=None, cu_seqlens_k=None, seqused_q=None, seqused_k=None):
        """FA4's rules: the offset is ``cu_seqlens[batch]`` (0 when dense); the length is
        ``seqused[batch]`` when given, else ``cu_seqlens[batch + 1] - cu_seqlens[batch]``,
        else the static (dense) length. Absent tensors are ``None`` at trace time."""

        def side(static_len, cu, used):
            if cu is not None:
                offset = fx.Int32(cu[batch])
                length = fx.Int32(cu[batch + fx.Int32(1)]) - offset
            else:
                offset = fx.Int32(0)
                length = fx.Int32(static_len)
            if used is not None:
                length = fx.Int32(used[batch])
            return offset, length

        offset_q, seqlen_q = side(seqlen_q_static, cu_seqlens_q, seqused_q)
        offset_k, seqlen_k = side(seqlen_k_static, cu_seqlens_k, seqused_k)
        return SeqlenInfo(offset_q, offset_k, seqlen_q, seqlen_k)
