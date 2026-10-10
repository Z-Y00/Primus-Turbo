#!/bin/bash
# Traces bench_kiwi_sdma_dispatch.py under rocprofv3 inside the ROCm container
# and keeps only the KIWI dispatch kernels and proxy HIP calls, so the result is
# small enough to copy off the node. Analyze it with kiwi_sdma_timeline.py.
#
# Usage: kiwi_sdma_trace.sh <output-dir> <bench_kiwi_sdma_dispatch.py args...>
# Env:   KIWI_REPO   repository to mount (default: this checkout)
#        KIWI_IMAGE  container image (default: rocm/primus:v26.7)
set -euo pipefail
if [ $# -lt 1 ]; then
  echo "usage: $0 <output-dir> <bench args...>" >&2
  exit 2
fi
out=$(realpath -m "$1"); shift
repo=${KIWI_REPO:-$(cd "$(dirname "$0")/../.." && pwd)}
image=${KIWI_IMAGE:-rocm/primus:v26.7}
rm -rf "$out"; mkdir -p "$out"
# The container runs as root; root-squashed home directories need this.
chmod 777 "$out"
docker run --rm --init --ulimit core=0 --device=/dev/kfd --device=/dev/dri \
  --group-add video --ipc=host \
  -e ROC_P2P_SDMA_SIZE="${ROC_P2P_SDMA_SIZE:-64}" \
  -e GPU_FORCE_BLIT_COPY_SIZE="${GPU_FORCE_BLIT_COPY_SIZE:-64}" \
  -e PYTHONPATH=/workspace/Primus-Turbo \
  -v "$repo:/workspace/Primus-Turbo" -v "$out:/prof" \
  -w /workspace/Primus-Turbo "$image" bash -lc "
    rocprofv3 --kernel-trace --hip-runtime-trace -f csv -d /tmp/prof -- \
      python benchmark/ops/training/bench_kiwi_sdma_dispatch.py $* 2>&1 | grep -E '^KIWI'
    cd /tmp/prof/*/
    for f in *_kernel_trace.csv *_hip_api_trace.csv; do
      grep -E 'kiwi|barrier|Batch|WriteValue|Start_Timestamp' \$f > /prof/\$f || true
    done
    chmod 666 /prof/*"
echo "trace written to $out"
