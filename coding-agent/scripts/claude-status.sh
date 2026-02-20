#!/bin/bash
# Show current Claude Code CLI configuration

echo "📊 Claude Code CLI Status"
echo "=========================="
echo ""

# Check environment variables
if [ -n "$ANTHROPIC_BASE_URL" ]; then
    echo "Mode: 🏠 LOCAL"
    echo ""
    echo "Configuration:"
    echo "  Base URL: $ANTHROPIC_BASE_URL"
    echo "  Model: ${ANTHROPIC_MODEL:-qwen2.5-coder:32b-instruct-q5_K_M}"
    echo "  API Key: ${ANTHROPIC_API_KEY:-sk-local}"
    if [ -n "$ANTHROPIC_API_KEY_BACKUP" ]; then
        echo "  💾 Original API key stored (will restore on cloud switch)"
    fi
    echo ""
    echo "Using: Self-hosted Qwen2.5-Coder model"

    # Check if server is reachable
    echo ""
    echo "Server status:"
    if curl -f -s -m 5 "http://unraid.clintonsteiner.com:3000/health" > /dev/null 2>&1; then
        echo "  ✅ Local server is reachable"
    else
        echo "  ❌ Local server is NOT reachable"
        echo "     Make sure coding-agent service is running on Unraid"
    fi
else
    echo "Mode: ☁️  CLOUD"
    echo ""
    echo "Configuration:"
    echo "  Base URL: (default - api.anthropic.com)"
    echo "  Model: (default or from ~/.claude/config.json)"
    if [ -n "$ANTHROPIC_API_KEY" ]; then
        echo "  API Key: ${ANTHROPIC_API_KEY:0:10}...${ANTHROPIC_API_KEY: -4}"
    else
        echo "  API Key: (from ~/.claude/config.json)"
    fi
    echo ""
    echo "Using: Anthropic's cloud API (Claude Sonnet/Opus)"
fi

echo ""
echo "Switch modes:"
echo "  Local:  source ~/claude-local"
echo "  Cloud:  source ~/claude-cloud"
