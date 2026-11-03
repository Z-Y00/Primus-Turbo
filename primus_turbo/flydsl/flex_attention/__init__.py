###############################################################################
# Copyright (c) 2026, Advanced Micro Devices, Inc. All rights reserved.
#
# See LICENSE for license information.
###############################################################################

"""FlyDSL flash/flex attention, structured after flash-attention's ``flash_attn/cute``
(FA4) and written for CDNA (gfx942 first). See ``flash_fwd.py``."""

from primus_turbo.flydsl.flex_attention.flash_fwd import FlashAttentionForward

__all__ = ["FlashAttentionForward"]
