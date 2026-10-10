###############################################################################
# Copyright (c) 2026, Advanced Micro Devices, Inc. All rights reserved.
#
# See LICENSE for license information.
###############################################################################

import os

import torch
import torch.distributed as dist
from torch.testing._internal.common_distributed import MultiProcessTestCase, skip_if_lt_x_gpu
from torch.testing._internal.common_utils import (
    instantiate_parametrized_tests,
    parametrize,
    run_tests,
)

import primus_turbo.pytorch as pt


@instantiate_parametrized_tests
class KiwiSdmaDispatchTest(MultiProcessTestCase):
    @property
    def world_size(self) -> int:
        return int(os.environ.get("KIWI_SDMA_TEST_WORLD_SIZE", "2"))

    def setUp(self) -> None:
        super().setUp()
        self._spawn_processes()

    def _buffer(self, hidden: int):
        torch.cuda.set_device(self.rank)
        store = dist.FileStore(self.file_name, self.world_size)
        dist.init_process_group(
            "nccl", rank=self.rank, world_size=self.world_size, store=store
        )
        config = pt.deep_ep.Config(8, 4, 64, 4, 64)
        Buffer = pt.deep_ep.Buffer
        max_tokens = max(1024, int(os.environ.get("KIWI_SDMA_TEST_TOKENS", "37")))
        nvl_bytes = Buffer.get_kiwi_sdma_nvl_buffer_size_hint(
            self.world_size,
            hidden * 2,
            max_tokens,
            num_topk=max(8, self.world_size),
            configs=(config, Buffer.get_combine_config(self.world_size)),
        )
        return Buffer(dist.group.WORLD, nvl_bytes), config

    @skip_if_lt_x_gpu(2)
    @parametrize("dtype", [torch.bfloat16, torch.float16])
    @parametrize("hidden", [2048, 7168])
    def test_dispatch_cached_and_cu_combine(self, dtype, hidden):
        for name in ("ROC_P2P_SDMA_SIZE", "GPU_FORCE_BLIT_COPY_SIZE"):
            assert os.environ.get(name, "").isdigit() and int(os.environ[name]) <= 1024, name
        tokens = int(os.environ.get("KIWI_SDMA_TEST_TOKENS", "37"))
        experts_per_rank = 2
        num_experts = experts_per_rank * self.world_size
        topk = self.world_size
        buffer, config = self._buffer(hidden)

        x = torch.full(
            (tokens, hidden), self.rank + 1, dtype=dtype, device="cuda"
        )
        topk_idx = (
            torch.arange(self.world_size, dtype=torch.int64, device="cuda")
            .mul(experts_per_rank)
            .repeat(tokens, 1)
        )
        topk_weights = torch.ones(
            (tokens, topk), dtype=torch.float32, device="cuda"
        )
        (
            num_tokens_per_rank,
            _,
            num_tokens_per_expert,
            is_token_in_rank,
            _,
        ) = buffer.get_dispatch_layout(topk_idx, num_experts)

        recv_x, recv_idx, recv_w, per_expert, handle, _ = buffer.dispatch_sdma(
            x,
            num_tokens_per_rank=num_tokens_per_rank,
            is_token_in_rank=is_token_in_rank,
            num_tokens_per_expert=num_tokens_per_expert,
            topk_idx=topk_idx,
            topk_weights=topk_weights,
            config=config,
        )
        torch.cuda.synchronize()
        assert recv_x.shape == (tokens * self.world_size, hidden)
        for source in range(self.world_size):
            rows = recv_x[source * tokens : (source + 1) * tokens]
            torch.testing.assert_close(
                rows,
                torch.full_like(rows, source + 1),
                rtol=0,
                atol=0,
            )
        assert recv_idx.ge(-1).all()
        assert recv_w.ge(0).all()
        assert sum(per_expert) == tokens * self.world_size

        turbo_x, turbo_idx, turbo_w, _, turbo_handle, _ = buffer.dispatch(
            x,
            num_tokens_per_rank=num_tokens_per_rank,
            is_token_in_rank=is_token_in_rank,
            num_tokens_per_expert=num_tokens_per_expert,
            topk_idx=topk_idx,
            topk_weights=topk_weights,
            config=config,
        )
        torch.cuda.synchronize()

        def canonical_order(src_idx, dispatch_handle):
            ends = dispatch_handle[0][:, self.rank].cpu().tolist()
            source = torch.empty_like(src_idx)
            begin = 0
            for src_rank, end in enumerate(ends):
                source[begin:end] = src_rank
                begin = end
            return torch.argsort(source.to(torch.int64) * tokens + src_idx)

        sdma_order = canonical_order(handle[3], handle)
        turbo_order = canonical_order(turbo_handle[3], turbo_handle)
        torch.testing.assert_close(
            recv_x[sdma_order], turbo_x[turbo_order], rtol=0, atol=0
        )
        torch.testing.assert_close(
            recv_idx[sdma_order], turbo_idx[turbo_order], rtol=0, atol=0
        )
        torch.testing.assert_close(
            recv_w[sdma_order], turbo_w[turbo_order], rtol=0, atol=0
        )

        cached_x, _, _, _, _, _ = buffer.dispatch_sdma(
            x, handle=handle, config=config
        )
        torch.cuda.synchronize()
        torch.testing.assert_close(cached_x, recv_x, rtol=0, atol=0)

        # Deferred receive: identical result once the hook has run, and no new
        # dispatch until then.
        hooked_x, _, _, _, _, _, hook = buffer.dispatch_sdma(
            x, handle=handle, config=config, return_recv_hook=True
        )
        with self.assertRaisesRegex(RuntimeError, "receive hook"):
            buffer.dispatch_sdma(x, handle=handle, config=config)
        hook()
        torch.cuda.synchronize()
        torch.testing.assert_close(hooked_x, recv_x, rtol=0, atol=0)

        if dtype == torch.bfloat16:
            combined, combined_weights, _ = buffer.combine(
                recv_x,
                handle,
                topk_weights=recv_w,
                config=config,
            )
            torch.cuda.synchronize()
            torch.testing.assert_close(
                combined / self.world_size, x, rtol=0, atol=0
            )
            torch.testing.assert_close(
                combined_weights, topk_weights, rtol=0, atol=0
            )

    @skip_if_lt_x_gpu(2)
    def test_zero_peer_duplicate_experts_and_negative_routes(self):
        tokens, hidden, num_experts = 11, 2048, self.world_size * 2
        buffer, config = self._buffer(hidden)
        x = torch.arange(
            tokens * hidden, dtype=torch.bfloat16, device="cuda"
        ).view(tokens, hidden)
        topk_idx = torch.full((tokens, 4), -1, dtype=torch.int64, device="cuda")
        # Three entries target rank 0, including a duplicate expert. The
        # transport must emit one row per token, while retaining all metadata.
        topk_idx[:, 0] = 0
        topk_idx[:, 1] = 1
        topk_idx[:, 2] = 0
        topk_weights = torch.rand((tokens, 4), dtype=torch.float32, device="cuda")
        per_rank, _, per_expert, mask, _ = buffer.get_dispatch_layout(
            topk_idx, num_experts
        )
        recv_x, recv_idx, recv_w, _, _, _ = buffer.dispatch_sdma(
            x,
            num_tokens_per_rank=per_rank,
            is_token_in_rank=mask,
            num_tokens_per_expert=per_expert,
            topk_idx=topk_idx,
            topk_weights=topk_weights,
            config=config,
        )
        torch.cuda.synchronize()
        expected_rows = tokens * self.world_size if self.rank == 0 else 0
        assert recv_x.size(0) == expected_rows
        if self.rank == 0:
            torch.testing.assert_close(
                recv_x,
                x.repeat(self.world_size, 1),
                rtol=0,
                atol=0,
            )
            assert recv_idx[:, 3].eq(-1).all()
            assert recv_w[:, 3].eq(0).all()

    @skip_if_lt_x_gpu(2)
    @parametrize("hidden", [2048, 7168])
    def test_fp8_data_scales_and_cached_replay(self, hidden):
        tokens, experts_per_rank = 19, 2
        num_experts = experts_per_rank * self.world_size
        buffer, config = self._buffer(hidden)
        x = torch.full(
            (tokens, hidden),
            self.rank + 1,
            dtype=torch.float32,
            device="cuda",
        ).to(torch.float8_e4m3fn)
        scales = torch.full(
            (tokens, hidden // 128),
            (self.rank + 1) / 8,
            dtype=torch.float32,
            device="cuda",
        )
        topk_idx = (
            torch.arange(self.world_size, dtype=torch.int64, device="cuda")
            .mul(experts_per_rank)
            .repeat(tokens, 1)
        )
        weights = torch.ones_like(topk_idx, dtype=torch.float32)
        per_rank, _, per_expert, mask, _ = buffer.get_dispatch_layout(
            topk_idx, num_experts
        )
        recv, _, _, _, handle, _ = buffer.dispatch_sdma(
            (x, scales),
            num_tokens_per_rank=per_rank,
            is_token_in_rank=mask,
            num_tokens_per_expert=per_expert,
            topk_idx=topk_idx,
            topk_weights=weights,
            config=config,
        )
        recv_x, recv_scales = recv
        torch.cuda.synchronize()
        for source in range(self.world_size):
            rows = slice(source * tokens, (source + 1) * tokens)
            torch.testing.assert_close(
                recv_x[rows].float(),
                torch.full_like(recv_x[rows].float(), source + 1),
                rtol=0,
                atol=0,
            )
            torch.testing.assert_close(
                recv_scales[rows],
                torch.full_like(recv_scales[rows], (source + 1) / 8),
                rtol=0,
                atol=0,
            )
        cached, _, _, _, _, _ = buffer.dispatch_sdma(
            (x, scales), handle=handle, config=config
        )
        torch.cuda.synchronize()
        cached_x, cached_scales = cached
        torch.testing.assert_close(cached_x.float(), recv_x.float(), rtol=0, atol=0)
        torch.testing.assert_close(cached_scales, recv_scales, rtol=0, atol=0)
        combined, _, _ = buffer.combine(
            torch.ones(
                (recv_x.size(0), hidden),
                dtype=torch.bfloat16,
                device="cuda",
            ),
            handle,
            config=config,
        )
        torch.cuda.synchronize()
        torch.testing.assert_close(
            combined,
            torch.full_like(combined, self.world_size),
            rtol=0,
            atol=0,
        )


if __name__ == "__main__":
    run_tests()
