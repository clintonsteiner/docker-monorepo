#!/bin/bash
set -e

echo "Downloading Qwen2.5-Coder-32B-Instruct (Q5_K_M quantization)"
echo "Model size: ~20GB"
echo "This may take 10-30 minutes depending on your connection..."
echo ""

# Check if docker is running
if ! docker ps &> /dev/null; then
    echo "Error: Docker is not running"
    exit 1
fi

# Check if container is running
if ! docker ps | grep -q coding-agent; then
    echo "Starting coding-agent container..."
    docker compose up -d
    sleep 5
fi

# Pull model via Ollama
echo "Pulling model via Ollama..."
docker exec coding-agent ollama pull qwen2.5-coder:32b-instruct-q5_K_M

echo ""
echo "✓ Model download complete!"
echo "  You can now use the model in the Web UI"
echo "  Access: http://unraid.clintonsteiner.com:3000"
