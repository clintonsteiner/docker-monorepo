#!/bin/bash
# Switch Claude Code CLI back to Anthropic's cloud API

echo "🔄 Switching Claude Code to Anthropic cloud API..."
echo ""

# Restore backed up API key if it exists
if [ -n "$ANTHROPIC_API_KEY_BACKUP" ]; then
    export ANTHROPIC_API_KEY="$ANTHROPIC_API_KEY_BACKUP"
    echo "🔑 Restored original API key"
    unset ANTHROPIC_API_KEY_BACKUP
else
    # If no backup, unset the key (will use ~/.claude/config.json)
    unset ANTHROPIC_API_KEY
fi

# Unset local server environment variables
unset ANTHROPIC_BASE_URL
unset ANTHROPIC_MODEL

echo ""
echo "✅ Claude Code is now using Anthropic cloud API"
echo ""
echo "Configuration:"
echo "  Base URL: (default - api.anthropic.com)"
echo "  Model: (default - claude-sonnet-4.5 or as configured)"
if [ -n "$ANTHROPIC_API_KEY" ]; then
    echo "  API Key: ${ANTHROPIC_API_KEY:0:10}...${ANTHROPIC_API_KEY: -4}"
else
    echo "  API Key: (using ~/.claude/config.json)"
fi
echo ""
echo "Usage: Run 'claude' as normal - it will use Anthropic's API!"
