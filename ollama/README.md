# vLLM-powered LLM Server for Claude CLI

A Docker-based LLM inference server using [vLLM](https://github.com/vllm-project/vllm) optimized for CPU-based inference with high RAM systems. Provides an OpenAI-compatible API that works seamlessly with the Claude CLI and other tools.

## Features

-  **vLLM**: Fast LLM inference engine with OpenAI-compatible API
-  **70B Model Support**: Optimized for running Llama-2-70B on CPU with sufficient RAM
-  **CPU-Optimized**: Runs on systems with 40+ GB RAM (no GPU required)
-  **OpenAI Compatible**: Works with Claude CLI, Python SDK, and other tools
-  **Model Selection**: Supports 7B, 13B, 70B, and custom HuggingFace models
- ️ **Caching**: Built-in prefix caching for faster repeated requests
-  **Health Checks**: Automatic health monitoring
-  **Non-root User**: Runs as unprivileged user

## Quick Start

### Prerequisites

- Docker and Docker Compose
- **Minimum 40GB RAM** for 70B model (4GB more for OS)
- 100GB+ disk space for model cache
- HuggingFace account with Llama-2 access (free)

### Build

```bash
make build
```

### Run with Default Model (70B)

```bash
make run
```

Server will start at `http://localhost:8000`

### Run with Different Model Sizes

```bash
# 70B model (largest, slowest, best quality)
make run-70b

# 13B model (medium, ~10-16GB RAM)
make run-13b

# 7B model (smallest, fastest, less capable)
make run-7b
```

## Usage with Claude CLI

Once the vLLM server is running, configure Claude CLI to use it:

### Option 1: Use with Claude CLI

```bash
# Set the API base URL
export CLAUDE_API_BASE="http://localhost:8000/v1"
export CLAUDE_API_KEY="sk-ollama-local"
export CLAUDE_MODEL="llama-2-70b"  # or your chosen model

# Now use Claude CLI
claude chat
```

### Option 2: Python SDK

```python
from anthropic import Anthropic

client = Anthropic(
    api_key="sk-ollama-local",
    base_url="http://localhost:8000/v1"
)

response = client.messages.create(
    model="llama-2-70b",
    max_tokens=1024,
    messages=[
        {
            "role": "user",
            "content": "Explain quantum computing in simple terms."
        }
    ]
)

print(response.content[0].text)
```

### Option 3: Direct API Calls

```bash
curl -X POST http://localhost:8000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "llama-2-70b",
    "messages": [
      {"role": "user", "content": "Hello, who are you?"}
    ],
    "temperature": 0.7,
    "max_tokens": 100
  }'
```

## Container Commands

```bash
# Build the image
make build

# Run tests
make test

# Start server (background)
make run

# View logs
make logs

# Stop server
make stop

# Clean up
make clean

# Push to registries
make push
```

## Environment Variables

Set these when running the container:

```bash
docker run -e MODEL_NAME="meta-llama/Llama-2-70b-hf" \
           -e DEVICE="cpu" \
           -e PORT="8000" \
           -e VLLM_LOGGING_LEVEL="INFO" \
           ollama:latest
```

| Variable | Default | Description |
|----------|---------|-------------|
| `MODEL_NAME` | `meta-llama/Llama-2-70b-hf` | HuggingFace model ID |
| `DEVICE` | `cpu` | Device type: `cpu` or `cuda` |
| `PORT` | `8000` | API server port |
| `TENSOR_PARALLEL_SIZE` | `1` | Number of tensor parallel groups |
| `MAX_MODEL_LEN` | `4096` | Maximum sequence length |
| `DTYPE` | `float16` | Data type: `float32`, `float16`, `bfloat16` |
| `VLLM_LOGGING_LEVEL` | `INFO` | Logging level |

## System Requirements

### For 70B Model (Llama-2-70b-hf)
- **RAM**: 40-50GB (float16) or 80GB+ (float32)
- **Disk**: 150GB (model + cache)
- **CPU**: 8+ cores recommended
- **OS**: Linux (Ubuntu 20.04+ recommended)

### For 13B Model
- **RAM**: 10-16GB
- **Disk**: 50GB
- **CPU**: 4+ cores

### For 7B Model
- **RAM**: 5-8GB
- **Disk**: 30GB
- **CPU**: 2+ cores

## Performance Tips

### For 70B Model on CPU

1. **Enable Swap**: Reserve swap space for fallback memory
   ```bash
   sudo fallocate -l 20G /swapfile
   sudo chmod 600 /swapfile
   sudo mkswap /swapfile
   sudo swapon /swapfile
   ```

2. **Memory Management**:
   ```bash
   docker run --memory 48g --memswap 48g ollama:latest
   ```

3. **Reduce Max Sequence Length**:
   ```bash
   docker run -e MAX_MODEL_LEN=2048 ollama:latest
   ```

4. **Use Smaller Batch Size**:
   ```bash
   docker run -e VLLM_NPROC_PER_NODE=1 ollama:latest
   ```

### CPU Optimization

- vLLM automatically optimizes for CPU inference
- Uses int8 quantization when available
- Implements prefix caching for repeated prompts

## Available Models

vLLM supports any model on HuggingFace Hub. Popular options:

| Model | Size | RAM | Speed | Quality |
|-------|------|-----|-------|---------|
| Llama-2-7b | 7B | 5-8GB |  |  |
| Llama-2-13b | 13B | 10-16GB |  |  |
| Llama-2-70b | 70B | 40-50GB |  |  |
| Mistral-7B | 7B | 5-8GB |  |  |
| CodeLlama-70b | 70B | 40-50GB |  |  |

## Troubleshooting

### Out of Memory (OOM) Errors

```
RuntimeError: CUDA out of memory
```

**Solution**: Reduce `MAX_MODEL_LEN` or use a smaller model:
```bash
docker run -e MAX_MODEL_LEN=2048 ollama:latest
```

### Model Download Issues

First run downloads the model (~30-150GB depending on model size):
```bash
# Stream logs to watch download progress
make logs

# Takes 10-60 minutes depending on connection speed
```

### API Not Responding

```bash
# Check if container is running
docker ps | grep ollama

# View logs for errors
make logs

# Restart
make stop
make run
```

### Slow Inference on CPU

This is expected. 70B model on CPU:
- First token: 30-60 seconds
- Subsequent tokens: 5-15 seconds each

For better performance, consider:
1. Using a smaller model (7B or 13B)
2. Using a GPU if available
3. Enabling quantization

## API Documentation

The server provides OpenAI-compatible endpoints:

### List Models

```bash
curl http://localhost:8000/v1/models
```

### Chat Completions

```bash
curl -X POST http://localhost:8000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "llama-2-70b",
    "messages": [
      {"role": "system", "content": "You are a helpful assistant."},
      {"role": "user", "content": "What is Python?"}
    ],
    "temperature": 0.7,
    "max_tokens": 256
  }'
```

### Text Completions

```bash
curl -X POST http://localhost:8000/v1/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "llama-2-70b",
    "prompt": "Write a Python function to calculate Fibonacci:",
    "temperature": 0.7,
    "max_tokens": 256
  }'
```

## Advanced Configuration

Edit `vllm-config.json` to customize:
- Token limits
- Batch sizes
- Caching strategies
- Model loading preferences

## Licensing

This project uses:
- **vLLM**: Apache 2.0
- **PyTorch**: BSD
- **Transformers**: Apache 2.0
- **Llama 2**: Llama Community License (free for research/commercial with restrictions)

## Resources

- [vLLM Documentation](https://docs.vllm.ai/)
- [Claude CLI Guide](../../../CONTRIBUTING.md)
- [Llama 2 Model Card](https://huggingface.co/meta-llama/Llama-2-70b)
- [HuggingFace Models](https://huggingface.co/models)

## Contributing

See [CONTRIBUTING.md](../CONTRIBUTING.md) for development guidelines.
