#!/bin/bash
# Start llama.cpp server with Qwen2.5-Coder-1.5B (Q8_0)
# Downloads model automatically on first run via Hugging Face.

set -e

MODEL="ggml-org/Qwen2.5-Coder-1.5B-Q8_0-GGUF"
PORT=8012

echo "Starting llama-server with $MODEL on port $PORT..."
echo "Model will be downloaded automatically on first launch."

exec llama-server \
  -hf "$MODEL" \
  --port "$PORT" -ngl 99 -fa auto -ub 1024 -b 1024 \
  --ctx-size 0 --cache-reuse 256
