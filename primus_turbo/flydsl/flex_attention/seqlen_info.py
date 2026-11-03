###############################################################################
# Copyright (c) 2026, Advanced Micro Devices, Inc. All rights reserved.
#
# See LICENSE for license information.
###############################################################################

"""Per-(batch) sequence lengths, the counterpart of FA4's ``seqlen_info.SeqlenInfoQK``."""

from dataclasses import dataclass

import flydsl.expr as fx


@dataclass
class SeqlenInfo:
    """Lengths seen by one CTA. ``offset`` is ``seqlen_k - seqlen_q``: causal and local
    masks are bottom-right aligned, as in FA4."""

    seqlen_q: fx.Int32
    seqlen_k: fx.Int32

    @property
    def offset(self) -> fx.Int32:
        return self.seqlen_k - self.seqlen_q

    @staticmethod
    def create_dense(seqlen_q, seqlen_k) -> "SeqlenInfo":
        return SeqlenInfo(fx.Int32(seqlen_q), fx.Int32(seqlen_k))
