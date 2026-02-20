FROM ghcr.io/open-webui/open-webui:main

LABEL org.opencontainers.image.title="Coding Agent"
LABEL org.opencontainers.image.description="Self-hosted Claude Code alternative powered by Qwen2.5-Coder-32B"
LABEL org.opencontainers.image.authors="Clinton Steiner <clintonsteiner@gmail.com>"
LABEL org.opencontainers.image.source="https://github.com/clintonsteiner/docker-monorepo"
LABEL org.opencontainers.image.licenses="MIT"

# Environment variables for optimal coding performance
ENV OLLAMA_NUM_PARALLEL=2 \
    OLLAMA_NUM_THREADS=12 \
    OLLAMA_NUM_CTX=32768 \
    OLLAMA_KEEP_ALIVE=30m \
    ENABLE_CODE_EXECUTION=true \
    CODE_EXECUTION_SANDBOX=true \
    WEBUI_AUTH=false \
    DEFAULT_MODEL="qwen2.5-coder:32b-instruct-q5_K_M"

# Create config directory
RUN mkdir -p /app/backend/data/config

# Copy custom configuration files
COPY config/ /app/backend/data/config/

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

# Expose port
EXPOSE 8080

# Use the parent image's entrypoint
