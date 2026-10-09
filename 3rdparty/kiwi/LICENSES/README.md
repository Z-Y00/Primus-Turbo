# License provenance

`hcqueue.txt` is the unchanged MIT license imported from AMD-RAD/hcqueue.
Its original code now lives in:

- `include/kiwi/queue/`, `include/kiwi/invoke/`, and `src/queue/`;
- `tests/queue/` and `tests/invoke/`;
- `benchmarks/queue/`, `benchmarks/invoke/`, `benchmarks/include/`, and
  `benchmarks/hardware/pcie_latency.hip.cpp`;
- `examples/queue/` and `examples/invoke/`.

The imported AMD-RAD/glci snapshot had no repository-level license file.
Moving it into `apps/`, `scripts/`, `docker/`, and shared documentation does
not assign it the hcqueue MIT license. In particular,
`benchmarks/hardware/bench_host_mapped_grid_poll.hip.cpp` also came from GLCI.
Combined build/documentation files contain material from both repositories.
Project-wide licensing remains an owner decision.

The source revisions in [the migration record](../docs/migration.md) preserve
the original trees, notices, and authorship for exact provenance.
