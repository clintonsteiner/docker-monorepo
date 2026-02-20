FROM ghcr.io/open-webui/open-webui:main

LABEL org.opencontainers.image.title="Coding Agent"
LABEL org.opencontainers.image.description="Self-hosted Claude Code alternative with Qwen2.5-Coder-32B baked in"
LABEL org.opencontainers.image.authors="Clinton Steiner <clintonsteiner@gmail.com>"
LABEL org.opencontainers.image.source="https://github.com/clintonsteiner/docker-monorepo"
LABEL org.opencontainers.image.licenses="MIT"

# Install Ollama for model management
USER root
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# hadolint ignore=DL3008
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl && \
    rm -rf /var/lib/apt/lists/* && \
    curl -fsSL https://ollama.com/install.sh | sh

# Environment variables for optimal coding performance
ENV OLLAMA_NUM_PARALLEL=2 \
    OLLAMA_NUM_THREADS=12 \
    OLLAMA_NUM_CTX=32768 \
    OLLAMA_KEEP_ALIVE=30m \
    ENABLE_CODE_EXECUTION=true \
    CODE_EXECUTION_SANDBOX=true \
    WEBUI_AUTH=false \
    DEFAULT_MODEL="qwen2.5-coder:32b-instruct-q5_K_M" \
    OLLAMA_MODELS=/root/.ollama/models

# Create necessary directories
RUN mkdir -p /app/backend/data/config ${OLLAMA_MODELS}

# Download Qwen2.5-Coder-32B model (~20GB) using Ollama
# This makes the image large but deployment is instant
# hadolint ignore=DL3001
RUN echo "Downloading Qwen2.5-Coder-32B model (~20GB)..." && \
    ollama serve > /tmp/ollama.log 2>&1 & \
    OLLAMA_PID=$! && \
    echo "Waiting for Ollama to start..." && \
    sleep 10 && \
    echo "Pulling model (this will take 10-30 minutes)..." && \
    ollama pull qwen2.5-coder:32b-instruct-q5_K_M && \
    echo "Stopping Ollama..." && \
    kill $OLLAMA_PID && \
    wait $OLLAMA_PID 2>/dev/null || true && \
    echo "Model successfully baked into image"

# Copy custom configuration files
COPY config/ /app/backend/data/config/

# Switch back to non-root user for security
USER 1000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

# Expose port
EXPOSE 8080

# Use the parent image's entrypoint
