# Vendored KIWI invoke subset

This directory contains the device-to-host queue and invoke subset from
[`AMD-RAD/kiwi`](https://github.com/AMD-RAD/kiwi), commit
`b5deea2517622d9ebd67476b7decec56e2ac8a39` (`origin/main` when imported).
That source commit is authored by Yan, Jiakun (`Jiakun.Yan@amd.com`); the
individual files retain their complete original copyright notices.

Imported paths:

- `include/kiwi/queue/{queue.hip.hpp,device_to_host_queue.hip.hpp,error.hpp}`
- `include/kiwi/queue/detail/{address_space.hpp,chunk.hip.hpp,host_memory.hpp}`
- `include/kiwi/invoke/`
- `src/queue/device_to_host_queue.cpp`
- `src/queue/host_memory.cpp`
- `src/queue/chunk_consumer.hpp`
- `LICENSES/hcqueue.txt`
- `LICENSES/README.md`

The files retain their original copyright and license notices. The imported
queue/invoke code is covered by the unchanged hcqueue MIT license in
`LICENSES/hcqueue.txt`. No KIWI application, LCI, P2P, EP, test, benchmark, or
build-system source is included.

Local adaptation: the three invoke headers that included the aggregate
`queue.hpp` include `device_to_host_queue.hip.hpp` directly, allowing the
unneeded H2D specializations to remain unvendored. No queue or invoke behavior
was changed.

The retained files keep KIWI's public `<kiwi/queue/...>` and
`<kiwi/invoke/...>` include paths.
