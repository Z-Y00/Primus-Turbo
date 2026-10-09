###############################################################################
# Copyright (c) 2026, Advanced Micro Devices, Inc. All rights reserved.
#
# See LICENSE for license information.
###############################################################################

"""Opt-in KIWI/SDMA transport shared by the MegaMoE BF16 and MXFP8 paths."""

import os

import torch


def enabled() -> bool:
    value = os.getenv("PRIMUS_TURBO_MEGA_MOE_DISPATCH", "").upper()
    if value not in ("", "CU", "KIWI_SDMA"):
        raise RuntimeError(
            "PRIMUS_TURBO_MEGA_MOE_DISPATCH must be CU or KIWI_SDMA"
        )
    return value == "KIWI_SDMA"


def _validate_environment() -> None:
    missing = [
        name
        for name in ("ROC_P2P_SDMA_SIZE", "GPU_FORCE_BLIT_COPY_SIZE")
        if os.getenv(name) != "0"
    ]
    if missing:
        raise RuntimeError(
            "MegaMoE KIWI_SDMA requires these variables to be 0 before process launch: "
            + ", ".join(missing)
        )


def dispatch_bf16(x, handle, symm, group) -> None:
    _validate_environment()
    # Re-arm only after the preceding GEMM on this stream has consumed the pool.
    # The host rendezvous prevents a faster peer from overwriting another rank
    # before that rank's re-arm has completed.
    symm.dispatch_token_pool.view(torch.int16).fill_(0x7F81)
    torch.cuda.synchronize(x.device)
    group.barrier().wait()
    torch.ops.primus_turbo_cpp_extension.mega_moe_kiwi_sdma_dispatch(
        x.contiguous(),
        None,
        handle[0],
        handle[1],
        handle[2],
        handle[3],
        handle[4],
        symm.dispatch_pool_ptrs,
        None,
    )


def dispatch_fp8(xq, xs, handle, symm) -> None:
    _validate_environment()
    # MegaMoE quantizes to E4M3 FNUZ: 0x7f is finite, while 0x80 is NaN.
    symm.pool_fp8.view(torch.uint8).fill_(0x80)
    symm.pool_scale.view(torch.uint8).fill_(0xFF)
    torch.cuda.synchronize(xq.device)
    symm.group.barrier().wait()
    torch.ops.primus_turbo_cpp_extension.mega_moe_kiwi_sdma_dispatch(
        xq.contiguous(),
        xs.contiguous(),
        handle[0],
        handle[1],
        handle[2],
        handle[3],
        handle[4],
        symm.pool_fp8_ptrs,
        symm.pool_scale_ptrs,
    )
