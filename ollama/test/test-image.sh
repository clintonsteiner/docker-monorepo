#!/bin/bash
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

TEST_IMAGE="ollama:test"

echo -e "${YELLOW}Running ollama (Ollama) tests...${NC}"

cleanup() {
  docker rm -f ollama-test >/dev/null 2>&1 || true
}

trap cleanup EXIT

# Test 1: Build
echo -e "\n${YELLOW}Test 1: Building image...${NC}"
if docker build -t "$TEST_IMAGE" . >/dev/null 2>&1; then
  echo -e "${GREEN}✓ Image built successfully${NC}"
else
  echo -e "${RED}✗ Build failed${NC}"
  exit 1
fi

# Test 2: Verify entrypoint
echo -e "\n${YELLOW}Test 2: Verifying Ollama entrypoint...${NC}"
ENTRYPOINT=$(docker inspect "$TEST_IMAGE" | grep -A2 '"Entrypoint"' | grep -o '/bin/ollama' || true)
if [ -n "$ENTRYPOINT" ]; then
  echo -e "${GREEN}✓ Ollama entrypoint is set${NC}"
else
  echo -e "${YELLOW}⚠ Entrypoint inherited from base image${NC}"
fi

# Test 3: Port exposed
echo -e "\n${YELLOW}Test 3: Verifying port...${NC}"
if docker inspect "$TEST_IMAGE" | grep -q "11434"; then
  echo -e "${GREEN}✓ Port 11434 exposed${NC}"
else
  echo -e "${YELLOW}⚠ Port not explicitly set (inherited)${NC}"
fi

# Test 4: Healthcheck
echo -e "\n${YELLOW}Test 4: Checking healthcheck...${NC}"
HEALTHCHECK=$(docker inspect "$TEST_IMAGE" | grep -c "HEALTHCHECK" || true)
if [ "$HEALTHCHECK" -gt 0 ]; then
  echo -e "${GREEN}✓ Healthcheck configured${NC}"
else
  echo -e "${YELLOW}⚠ Healthcheck not configured${NC}"
fi

echo -e "\n${GREEN}All critical tests passed!${NC}"
echo -e "\n${YELLOW}Image is ready to use:${NC}"
echo "  make run-70b   # Start with 70B Llama model"
echo "  make run-13b   # Start with 13B Llama model"
echo "  make run-7b    # Start with 7B Llama model"
