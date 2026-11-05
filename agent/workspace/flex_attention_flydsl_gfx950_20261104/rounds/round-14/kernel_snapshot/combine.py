###############################################################################
# Copyright (c) 2026, Advanced Micro Devices, Inc. All rights reserved.
#
# See LICENSE for license information.
###############################################################################

"""Split-KV combine, FA4's ``flash_attn_combine`` (as torch ops for now)."""

from typing import Optional, Tuple

import torch


def flash_attn_combine(
    out_partial: torch.Tensor,
    lse_partial: torch.Tensor,
    out: Optional[torch.Tensor] = None,
    out_dtype: Optional[torch.dtype] = None,
    return_lse: bool = True,
) -> Tuple[torch.Tensor, Optional[torch.Tensor]]:
    """Merge per-split normalized outputs by their LSEs.

    ``out_partial``: ``[num_splits, B, S, H, Dv]`` or ``[num_splits, T, H, Dv]`` (fp32).
    ``lse_partial``: ``[num_splits, B, S, H]`` or ``[num_splits, T, H]`` (FA4's layout).
    Returns ``(out, lse)`` with ``lse`` shaped like one split of ``lse_partial``. A row
    no split saw gives O = 0 and LSE = -inf.
    """
    lse = torch.logsumexp(lse_partial, dim=0)
    weight = torch.exp(lse_partial - lse.unsqueeze(0)).nan_to_num(0.0)
    combined = (out_partial * weight.unsqueeze(-1)).sum(0)
    out_dtype = out_dtype or (out.dtype if out is not None else torch.bfloat16)
    if out is None:
        out = combined.to(out_dtype)
    else:
        out.copy_(combined)
    return out, (lse if return_lse else None)
