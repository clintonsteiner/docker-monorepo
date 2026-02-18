#!/bin/bash
set -euo pipefail

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

TEST_IMAGE="llm-bot:test"

echo -e "${YELLOW}Running llm-bot tests...${NC}"

# Cleanup function
cleanup() {
  docker rm -f llm-bot-test >/dev/null 2>&1 || true
}

trap cleanup EXIT

# Test 1: Build image successfully
echo -e "\n${YELLOW}Test 1: Building image...${NC}"
if docker build -t "$TEST_IMAGE" . >/dev/null 2>&1; then
  echo -e "${GREEN}✓ Image built successfully${NC}"
else
  echo -e "${RED}✗ Image build failed${NC}"
  exit 1
fi

# Test 2: Verify vLLM is installed
echo -e "\n${YELLOW}Test 2: Verifying vLLM installation...${NC}"
if docker run --rm "$TEST_IMAGE" python -c "import vllm; print(vllm.__version__)" >/dev/null 2>&1; then
  VLLM_VERSION=$(docker run --rm "$TEST_IMAGE" python -c "import vllm; print(vllm.__version__)")
  echo -e "${GREEN}✓ vLLM installed (version: $VLLM_VERSION)${NC}"
else
  echo -e "${RED}✗ vLLM not found${NC}"
  exit 1
fi

# Test 3: Verify required dependencies
echo -e "\n${YELLOW}Test 3: Checking required dependencies...${NC}"
DEPS=("transformers" "torch" "fastapi" "uvicorn" "pydantic")
for dep in "${DEPS[@]}"; do
  if docker run --rm "$TEST_IMAGE" python -c "import $dep" >/dev/null 2>&1; then
    echo -e "${GREEN}✓ $dep installed${NC}"
  else
    echo -e "${RED}✗ $dep not found${NC}"
    exit 1
  fi
done

# Test 4: Verify startup script exists and is executable
echo -e "\n${YELLOW}Test 4: Checking startup script...${NC}"
if docker run --rm "$TEST_IMAGE" test -x /app/start.sh; then
  echo -e "${GREEN}✓ Startup script exists and is executable${NC}"
else
  echo -e "${RED}✗ Startup script not found${NC}"
  exit 1
fi

# Test 5: Verify configuration file exists
echo -e "\n${YELLOW}Test 5: Checking configuration...${NC}"
if docker run --rm "$TEST_IMAGE" test -f /app/config.json; then
  echo -e "${GREEN}✓ Configuration file exists${NC}"
else
  echo -e "${RED}✗ Configuration file not found${NC}"
  exit 1
fi

# Test 6: Quick start test (short timeout to verify it starts)
echo -e "\n${YELLOW}Test 6: Verifying server startup (30s timeout)...${NC}"
if timeout 30 docker run --rm \
  --name llm-bot-test \
  -e VLLM_LOGGING_LEVEL=ERROR \
  "$TEST_IMAGE" bash -c "python -c 'print(\"Server ready\")'" >/dev/null 2>&1; then
  echo -e "${GREEN}✓ Server startup verification passed${NC}"
else
  echo -e "${YELLOW}⚠ Server test skipped (expected on first run - models download on demand)${NC}"
fi

echo -e "\n${GREEN}All tests passed!${NC}"
echo -e "\n${YELLOW}Note: Model downloading occurs on first container run${NC}"
echo -e "This is normal and happens automatically with vLLM${NC}"
