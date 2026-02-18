# Ollama - Simple, fast LLM server for Claude CLI
# Built on official Ollama image with minimal overhead
# hadolint ignore=DL3007
FROM ollama/ollama:0.1.47

# Health check for container orchestration
HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
    CMD curl -f http://127.0.0.1:11434/api/tags || exit 1

# Expose Ollama API port
EXPOSE 11434

# Run Ollama server
CMD ["ollama", "serve"]
