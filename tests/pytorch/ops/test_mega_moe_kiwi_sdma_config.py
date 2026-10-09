###############################################################################
# Copyright (c) 2026, Advanced Micro Devices, Inc. All rights reserved.
#
# See LICENSE for license information.
###############################################################################

import importlib.util
from pathlib import Path

import pytest

_SDMA_PATH = (
    Path(__file__).parents[3] / "primus_turbo" / "flydsl" / "mega" / "sdma.py"
)
_SPEC = importlib.util.spec_from_file_location("mega_moe_sdma_config", _SDMA_PATH)
assert _SPEC is not None and _SPEC.loader is not None
sdma = importlib.util.module_from_spec(_SPEC)
_SPEC.loader.exec_module(sdma)


def test_mega_moe_sdma_is_opt_in(monkeypatch):
    monkeypatch.delenv("PRIMUS_TURBO_MEGA_MOE_DISPATCH", raising=False)
    assert not sdma.enabled()
    monkeypatch.setenv("PRIMUS_TURBO_MEGA_MOE_DISPATCH", "CU")
    assert not sdma.enabled()
    monkeypatch.setenv("PRIMUS_TURBO_MEGA_MOE_DISPATCH", "kiwi_sdma")
    assert sdma.enabled()


def test_mega_moe_sdma_rejects_unknown_selection(monkeypatch):
    monkeypatch.setenv("PRIMUS_TURBO_MEGA_MOE_DISPATCH", "other")
    with pytest.raises(RuntimeError, match="CU or KIWI_SDMA"):
        sdma.enabled()


def test_mega_moe_sdma_requires_blit_environment(monkeypatch):
    monkeypatch.delenv("ROC_P2P_SDMA_SIZE", raising=False)
    monkeypatch.setenv("GPU_FORCE_BLIT_COPY_SIZE", "0")
    with pytest.raises(RuntimeError, match="ROC_P2P_SDMA_SIZE"):
        sdma._validate_environment()

    monkeypatch.setenv("ROC_P2P_SDMA_SIZE", "0")
    monkeypatch.setenv("GPU_FORCE_BLIT_COPY_SIZE", "1")
    with pytest.raises(RuntimeError, match="GPU_FORCE_BLIT_COPY_SIZE"):
        sdma._validate_environment()

    monkeypatch.setenv("GPU_FORCE_BLIT_COPY_SIZE", "0")
    sdma._validate_environment()
