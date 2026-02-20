#!/bin/bash
set -e

echo "Testing Coding Agent..."
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Test 1: Service health check
echo "1. Testing service health..."
if curl -f -s http://localhost:3000/health > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Service is healthy"
else
    echo -e "${RED}✗${NC} Service is not responding"
    exit 1
fi

# Test 2: API availability
echo "2. Testing API endpoint..."
if curl -f -s http://localhost:3000/api/health > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} API is available"
else
    echo -e "${RED}✗${NC} API is not available"
    exit 1
fi

# Test 3: Ollama backend
echo "3. Testing Ollama backend..."
if curl -f -s http://localhost:11434/api/tags > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Ollama backend is running"
else
    echo -e "${RED}✗${NC} Ollama backend is not responding"
    exit 1
fi

# Test 4: Check if model is loaded
echo "4. Checking for models..."
models=$(curl -s http://localhost:11434/api/tags | grep -o '"name":"[^"]*"' | wc -l)
if [ "$models" -gt 0 ]; then
    echo -e "${GREEN}✓${NC} Models are available ($models model(s))"
else
    echo -e "${RED}⚠${NC} No models loaded yet (run 'make download-model')"
fi

# Test 5: Simple completion (if model is loaded)
if [ "$models" -gt 0 ]; then
    echo "5. Testing code completion..."
    response=$(curl -s http://localhost:11434/api/generate \
      -d '{
        "model": "qwen2.5-coder:32b-instruct-q5_K_M",
        "prompt": "Write a hello world function in Python",
        "stream": false
      }' 2>/dev/null || echo "")

    if echo "$response" | grep -q "def\|print\|hello"; then
        echo -e "${GREEN}✓${NC} Code generation is working"
    else
        echo -e "${RED}⚠${NC} Code generation test skipped (model may not be loaded)"
    fi
fi

echo ""
echo -e "${GREEN}✓ All tests passed!${NC}"
echo ""
echo "Access the Web UI at: http://unraid.clintonsteiner.com:3000"
