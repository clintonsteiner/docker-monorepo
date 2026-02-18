# vLLM server for running 70B LLMs on CPU with high RAM
# Supports OpenAI-compatible API for use with Claude CLI and other tools
FROM python:3.11-slim

# Set environment variables for vLLM optimization
ENV PYTHONUNBUFFERED=1 \
    VLLM_NPROC_PER_NODE=1 \
    VLLM_CPU_ONLY=1 \
    VLLM_LOGGING_LEVEL=INFO \
    PYTORCH_ENABLE_MPS_FALLBACK=1 \
    TOKENIZERS_PARALLELISM=false

# Install system dependencies
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        curl \
        git \
        ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Install vLLM and dependencies with caching
WORKDIR /app

RUN --mount=type=cache,target=/root/.cache/pip,sharing=locked \
    pip install --no-cache-dir \
        vllm==0.5.4 \
        torch==2.1.2 \
        transformers==4.38.2 \
        numpy==1.24.3 \
        pydantic==2.4.2 \
        fastapi==0.110.1 \
        uvicorn==0.29.0 \
        pydantic-settings==2.1.0 \
        aiohttp==3.9.1 \
        requests==2.31.0

# Copy configuration
COPY vllm-config.json /app/config.json
COPY start.sh /app/start.sh

RUN chmod +x /app/start.sh

# Create non-root user
RUN useradd -m -s /bin/bash vllm && \
    chown -R vllm:vllm /app

USER vllm

# Health check (checks if API is responding)
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://127.0.0.1:8000/v1/models || exit 1

# Expose vLLM API port
EXPOSE 8000

# Default command runs vLLM server
CMD ["/app/start.sh"]
