#!/bin/bash
set -euo pipefail

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Extract expected Caddy version from Dockerfile
EXPECTED_VERSION=$(grep "^FROM caddy:" Dockerfile | head -1 | sed 's/.*:\([^-]*\).*/\1/')
TEST_IMAGE="caddy-cloudflaredns:test"
CONTAINER_NAME="caddy-cloudflaredns-test"

echo -e "${YELLOW}Running caddy-cloudflaredns tests...${NC}"
echo "Expected Caddy version: $EXPECTED_VERSION"

# Cleanup function
cleanup() {
  docker rm -f "$CONTAINER_NAME" >/dev/null 2>&1 || true
}

trap cleanup EXIT

# Note: Image is pre-built in workflow, just verify it exists
echo -e "\n${YELLOW}Test 1: Verifying pre-built image...${NC}"
if docker image inspect "$TEST_IMAGE" >/dev/null 2>&1; then
  echo -e "${GREEN}✓ Image ready for testing${NC}"
else
  echo -e "${RED}✗ Image not found${NC}"
  exit 1
fi

# Test 2: Verify Caddy binary exists and is executable
echo -e "\n${YELLOW}Test 2: Verifying Caddy binary...${NC}"
if docker run --rm "$TEST_IMAGE" test -x /usr/bin/caddy; then
  echo -e "${GREEN}✓ Caddy binary exists and is executable${NC}"
else
  echo -e "${RED}✗ Caddy binary not found or not executable${NC}"
  exit 1
fi

# Test 3: Verify Caddy version matches Dockerfile
echo -e "\n${YELLOW}Test 3: Checking Caddy version...${NC}"
ACTUAL_VERSION=$(docker run --rm "$TEST_IMAGE" /usr/bin/caddy version | grep -o 'v[0-9.]*' | sed 's/v//')
if [[ "$ACTUAL_VERSION" == "$EXPECTED_VERSION" ]]; then
  echo -e "${GREEN}✓ Caddy version matches: v${ACTUAL_VERSION}${NC}"
else
  echo -e "${RED}✗ Version mismatch. Expected: ${EXPECTED_VERSION}, Got: ${ACTUAL_VERSION}${NC}"
  exit 1
fi

# Test 4: Verify Cloudflare DNS module is installed
echo -e "\n${YELLOW}Test 4: Checking Cloudflare DNS module...${NC}"
if docker run --rm "$TEST_IMAGE" /usr/bin/caddy list-modules | grep -q cloudflare; then
  echo -e "${GREEN}✓ Cloudflare DNS module is installed${NC}"
else
  echo -e "${RED}✗ Cloudflare DNS module not found${NC}"
  exit 1
fi

# Test 5: Verify Caddy configuration validation works
echo -e "\n${YELLOW}Test 5: Testing Caddy configuration validation...${NC}"
TEST_CADDYFILE="localhost:2015
respond \"Hello\""

if echo "$TEST_CADDYFILE" | docker run --rm -e ACME_AGREE=true -i "$TEST_IMAGE" /usr/bin/caddy validate --config /dev/stdin --adapter caddyfile >/dev/null 2>&1; then
  echo -e "${GREEN}✓ Caddy configuration validation works${NC}"
else
  echo -e "${RED}✗ Caddy configuration validation failed${NC}"
  exit 1
fi

echo -e "\n${GREEN}All tests passed!${NC}"
