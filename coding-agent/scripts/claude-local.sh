#!/bin/bash
# Switch Claude Code CLI to use local Qwen2.5-Coder model

echo "🔄 Switching Claude Code to local model..."
echo ""

# Store current API key if it exists and isn't already stored
if [ -n "$ANTHROPIC_API_KEY" ] && [ "$ANTHROPIC_API_KEY" != "sk-local" ]; then
    export ANTHROPIC_API_KEY_BACKUP="$ANTHROPIC_API_KEY"
    echo "💾 Stored existing API key"
    echo ""
fi

# Set environment variables to point to local server
export ANTHROPIC_BASE_URL="http://unraid.clintonsteiner.com:3000/v1"
export ANTHROPIC_API_KEY="sk-local"
export ANTHROPIC_MODEL="qwen2.5-coder:32b-instruct-q5_K_M"

echo "✅ Claude Code is now using local model"
echo ""
echo "Configuration:"
echo "  Base URL: $ANTHROPIC_BASE_URL"
echo "  Model: $ANTHROPIC_MODEL"
echo ""
if [ -n "$ANTHROPIC_API_KEY_BACKUP" ]; then
    echo "💾 Your original API key is stored and will be restored when switching back to cloud"
    echo ""
fi
echo "⚠️  Note: This only affects the current shell session."
echo "   To make it permanent, add these exports to your ~/.bashrc or ~/.zshrc"
echo ""
echo "Usage: Run 'claude' as normal - it will use your local model!"
