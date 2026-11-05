###############################################################################
# Copyright (c) 2026, Advanced Micro Devices, Inc. All rights reserved.
#
# See LICENSE for license information.
###############################################################################

"""Deterministic flash attention backward in FlyDSL: one implementation per target.

``flash_bwd_gfx942.py`` (MI300) and ``flash_bwd_gfx950.py`` (MI355) share the design (separate
dQ and dK/dV kernels, each owning its output, after FA4's ``flash_bwd.py``) but are tuned and
evolve separately. ``FlashAttentionBackward`` builds the one for the current device.
"""

import torch


def FlashAttentionBackward(*args, **kwargs):  # noqa: N802 - constructor-style factory
    """The backward builder for the current device (same arguments for both targets)."""
    arch = torch.cuda.get_device_properties(torch.cuda.current_device()).gcnArchName
    if "gfx95" in arch:
        from primus_turbo.flydsl.flex_attention.flash_bwd_gfx950 import FlashAttentionBackward as impl
    else:
        from primus_turbo.flydsl.flex_attention.flash_bwd_gfx942 import FlashAttentionBackward as impl
    return impl(*args, **kwargs)
