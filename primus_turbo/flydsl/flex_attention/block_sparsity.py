###############################################################################
# Copyright (c) 2026, Advanced Micro Devices, Inc. All rights reserved.
#
# See LICENSE for license information.
###############################################################################

"""Block-sparse KV lists, FA4's ``BlockSparseTensorsTorch`` (fixed-length layout).

For each (batch, head, sparse Q block): ``mask_block_cnt`` / ``mask_block_idx`` list
the sparse KV blocks that are partly masked (mask_mod is evaluated there) and
``full_block_cnt`` / ``full_block_idx`` the blocks that are entirely kept (mask_mod
is skipped). Counts are ``[B, H, M]`` int32, indices ``[B, H, M, N]`` int32 packed to
the left; ``H`` may be 1 to share one pattern across heads. ``block_size`` is the
sparse ``(q, kv)`` block, a multiple of the kernel's ``(tile_m, tile_n)``; ``None``
means the kernel tile.
"""

from typing import NamedTuple, Optional, Tuple

import torch


class BlockSparseTensors(NamedTuple):
    mask_block_cnt: torch.Tensor
    mask_block_idx: torch.Tensor
    full_block_cnt: Optional[torch.Tensor] = None
    full_block_idx: Optional[torch.Tensor] = None
    block_size: Optional[Tuple[int, int]] = None


def subtile_factors(block_size, tile_m: int, tile_n: int) -> Tuple[int, int]:
    """``(q, kv)`` number of kernel tiles per sparse block."""
    sparse_q, sparse_kv = (tile_m, tile_n) if block_size is None else block_size
    if sparse_q % tile_m or sparse_kv % tile_n:
        raise ValueError(f"sparse block size {(sparse_q, sparse_kv)} must be a multiple of the tile {(tile_m, tile_n)}")
    return sparse_q // tile_m, sparse_kv // tile_n


def broadcast_heads(tensors: BlockSparseTensors, num_heads: int) -> BlockSparseTensors:
    """Expand a head dimension of 1 to ``num_heads`` (a stride-0 view, no copy)."""

    def expand(t):
        if t is None or t.shape[1] == num_heads:
            return t
        if t.shape[1] != 1:
            raise ValueError(f"block-sparse head dim must be 1 or {num_heads}, got {t.shape[1]}")
        return t.expand(t.shape[0], num_heads, *t.shape[2:])

    return tensors._replace(
        mask_block_cnt=expand(tensors.mask_block_cnt),
        mask_block_idx=expand(tensors.mask_block_idx),
        full_block_cnt=expand(tensors.full_block_cnt),
        full_block_idx=expand(tensors.full_block_idx),
    )


def dense_to_block_sparse(
    dense_mask: torch.Tensor, block_size: Tuple[int, int]
) -> BlockSparseTensors:
    """Classify a dense ``[B, H, Sq, Sk]`` bool mask into partial / full block lists
    (a testing and fallback utility; FA4's ``compute_block_sparsity`` does this on GPU
    from a mask_mod)."""
    B, H, Sq, Sk = dense_mask.shape
    bq, bk = block_size
    M, N = -(-Sq // bq), -(-Sk // bk)
    padded = torch.zeros(B, H, M * bq, N * bk, dtype=torch.bool, device=dense_mask.device)
    valid = torch.zeros_like(padded)
    padded[..., :Sq, :Sk] = dense_mask
    valid[..., :Sq, :Sk] = True
    blocks = padded.view(B, H, M, bq, N, bk)
    valid_blocks = valid.view(B, H, M, bq, N, bk)
    any_kept = blocks.any(dim=(3, 5))
    all_kept = (blocks | ~valid_blocks).all(dim=(3, 5)) & any_kept
    partial = any_kept & ~all_kept

    def to_lists(sel):
        cnt = sel.sum(-1).to(torch.int32)
        order = torch.argsort((~sel).to(torch.int8), dim=-1, stable=True).to(torch.int32)
        return cnt.contiguous(), order.contiguous()

    mask_cnt, mask_idx = to_lists(partial)
    full_cnt, full_idx = to_lists(all_kept)
    return BlockSparseTensors(mask_cnt, mask_idx, full_cnt, full_idx, block_size)
