#!/bin/bash
# EP8 whole-MoE forward with a shared expert, serial vs overlapped dispatch.
# Runs inside the ROCm container with the repository at /workspace/Primus-Turbo,
# e.g. docker run ... -v $REPO:/workspace/Primus-Turbo rocm/primus:v26.7 bash <this script>.
set -u
cd /workspace/Primus-Turbo
export PYTHONPATH=/workspace/Primus-Turbo ROC_P2P_SDMA_SIZE=64 GPU_FORCE_BLIT_COPY_SIZE=64
MOE="benchmark/ops/training/bench_moe_ep_backend.py --mode forward --num-processes 8 --num-tokens 4096 --hidden 7168 --intermediate 2048 --num-experts 256 --topk 8 --num-sms 20 --warmup 3 --iterations 10 --breakdown"

run() {
    local label=$1; shift
    echo "### $label"
    timeout 300 python -u $MOE "$@" > /tmp/run.log 2>&1
    echo "exit=$?"
    grep -E "^MOE|KIWI_SDMA_(FAILURE|PROXY_ERROR|DEVICE)|Error" /tmp/run.log | cut -c1-400
}

for s in 2048 8192; do
    run "TURBO serial, shared $s" --backend TURBO --shared-intermediate $s
    run "TURBO comm-stream + hook, shared $s" --backend TURBO --shared-intermediate $s --comm-stream --recv-hook
    run "KIWI serial, shared $s" --backend KIWI_SDMA --shared-intermediate $s
    run "KIWI hook, shared $s" --backend KIWI_SDMA --shared-intermediate $s --recv-hook
    run "KIWI comm-stream + hook, shared $s" --backend KIWI_SDMA --shared-intermediate $s --comm-stream --recv-hook
done
echo DONE
