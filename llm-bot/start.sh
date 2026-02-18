#!/bin/bash
set -euo pipefail

# vLLM startup script with configuration

# Default values
MODEL="${MODEL_NAME:-meta-llama/Llama-2-70b-hf}"
TENSOR_PARALLEL="${TENSOR_PARALLEL_SIZE:-1}"
MAX_MODEL_LEN="${MAX_MODEL_LEN:-4096}"
DTYPE="${DTYPE:-float16}"
DEVICE="${DEVICE:-cpu}"
PORT="${PORT:-8000}"
HOST="${HOST:-0.0.0.0}"

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                  vLLM Server Starting                          ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""
echo "Configuration:"
echo "  Model: $MODEL"
echo "  Device: $DEVICE"
echo "  Tensor Parallel Size: $TENSOR_PARALLEL"
echo "  Max Model Length: $MAX_MODEL_LEN"
echo "  Data Type: $DTYPE"
echo "  Server: http://$HOST:$PORT"
echo ""
echo "Starting vLLM server..."
echo ""

# Check if model is already downloaded, if not it will be downloaded on first start
if [ "$DEVICE" = "cpu" ]; then
  echo "⚠️  Running on CPU - this will be slower than GPU"
  echo "   Ensure your system has sufficient RAM for the model"
  echo ""

  # Run vLLM with CPU-specific optimizations
  python -m vllm.entrypoints.openai.api_server \
    --model "$MODEL" \
    --tensor-parallel-size "$TENSOR_PARALLEL" \
    --max-model-len "$MAX_MODEL_LEN" \
    --dtype "$DTYPE" \
    --device "$DEVICE" \
    --host "$HOST" \
    --port "$PORT" \
    --api-key sk-${MODEL_NAME//\//_} \
    --trust-remote-code \
    --disable-log-requests \
    --served-model-name "${MODEL##*/}" || exit 1
else
  # GPU mode (if available)
  python -m vllm.entrypoints.openai.api_server \
    --model "$MODEL" \
    --tensor-parallel-size "$TENSOR_PARALLEL" \
    --max-model-len "$MAX_MODEL_LEN" \
    --dtype "$DTYPE" \
    --host "$HOST" \
    --port "$PORT" \
    --api-key sk-${MODEL_NAME//\//_} \
    --trust-remote-code \
    --disable-log-requests \
    --served-model-name "${MODEL##*/}" || exit 1
fi
