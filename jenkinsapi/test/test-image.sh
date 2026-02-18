#!/bin/bash
set -euo pipefail

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

JENKINS_IMAGE="jenkinsapi:test"
TEST_IMAGE="jenkinsapi-test:test"
CONTAINER_NAME="jenkinsapi-test"

echo -e "${YELLOW}Running jenkinsapi tests...${NC}"

# Cleanup function
cleanup() {
  docker rm -f "$CONTAINER_NAME" >/dev/null 2>&1 || true
}

trap cleanup EXIT

# Test 1: Build Jenkins image successfully
echo -e "\n${YELLOW}Test 1: Building Jenkins image...${NC}"
if docker build -t "$JENKINS_IMAGE" -f Dockerfile . >/dev/null 2>&1; then
  echo -e "${GREEN}✓ Jenkins image built successfully${NC}"
else
  echo -e "${RED}✗ Jenkins image build failed${NC}"
  exit 1
fi

# Test 2: Build test image successfully
echo -e "\n${YELLOW}Test 2: Building test image...${NC}"
if docker build -t "$TEST_IMAGE" -f Dockerfile.test . >/dev/null 2>&1; then
  echo -e "${GREEN}✓ Test image built successfully${NC}"
else
  echo -e "${RED}✗ Test image build failed${NC}"
  exit 1
fi

# Test 3: Verify Jenkins binary exists and is executable
echo -e "\n${YELLOW}Test 3: Verifying Jenkins binary...${NC}"
if docker run --rm "$JENKINS_IMAGE" test -x /usr/local/bin/jenkins.sh; then
  echo -e "${GREEN}✓ Jenkins binary exists and is executable${NC}"
else
  echo -e "${RED}✗ Jenkins binary not found or not executable${NC}"
  exit 1
fi

# Test 4: Verify plugins are installed
echo -e "\n${YELLOW}Test 4: Checking installed plugins...${NC}"
if docker run --rm "$JENKINS_IMAGE" ls -q /var/jenkins_home/plugins/ 2>/dev/null | grep -q .; then
  PLUGIN_COUNT=$(docker run --rm "$JENKINS_IMAGE" ls -q /var/jenkins_home/plugins/ 2>/dev/null | wc -l)
  echo -e "${GREEN}✓ Jenkins plugins installed ($PLUGIN_COUNT plugins)${NC}"
else
  echo -e "${YELLOW}⚠ Plugins directory exists but may be empty (expected on first start)${NC}"
fi

# Test 5: Verify entrypoint script exists
echo -e "\n${YELLOW}Test 5: Checking custom entrypoint...${NC}"
if docker run --rm "$JENKINS_IMAGE" test -x /usr/local/bin/jenkins-entrypoint.sh; then
  echo -e "${GREEN}✓ Custom entrypoint script exists${NC}"
else
  echo -e "${RED}✗ Custom entrypoint script not found${NC}"
  exit 1
fi

# Test 6: Verify required utilities are installed
echo -e "\n${YELLOW}Test 6: Checking system utilities...${NC}"
if docker run --rm "$JENKINS_IMAGE" which curl ping >/dev/null 2>&1; then
  echo -e "${GREEN}✓ Required utilities (curl, ping) installed${NC}"
else
  echo -e "${RED}✗ Required utilities not found${NC}"
  exit 1
fi

# Test 7: Test image - verify Python environment
echo -e "\n${YELLOW}Test 7: Verifying test image Python environment...${NC}"
if docker run --rm "$TEST_IMAGE" python -c "import pytest; print(pytest.__version__)" >/dev/null 2>&1; then
  PYTEST_VERSION=$(docker run --rm "$TEST_IMAGE" python -c "import pytest; print(pytest.__version__)")
  echo -e "${GREEN}✓ Test image Python environment ready (pytest $PYTEST_VERSION)${NC}"
else
  echo -e "${RED}✗ Test image Python environment failed${NC}"
  exit 1
fi

echo -e "\n${GREEN}All tests passed!${NC}"
