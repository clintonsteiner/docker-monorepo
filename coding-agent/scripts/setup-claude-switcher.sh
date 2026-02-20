#!/bin/bash
# Setup script to install Claude CLI switcher functions

set -e

echo "🔧 Setting up Claude Code CLI switcher..."
echo ""

# Detect shell
SHELL_NAME=$(basename "$SHELL")
if [ "$SHELL_NAME" = "zsh" ]; then
    RC_FILE="$HOME/.zshrc"
elif [ "$SHELL_NAME" = "bash" ]; then
    RC_FILE="$HOME/.bashrc"
else
    echo "⚠️  Unknown shell: $SHELL_NAME"
    echo "Please manually add the functions to your shell configuration file"
    exit 1
fi

echo "Detected shell: $SHELL_NAME"
echo "Configuration file: $RC_FILE"
echo ""

# Copy scripts to home directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Copying scripts to home directory..."
cp "$SCRIPT_DIR/claude-local.sh" "$HOME/claude-local"
cp "$SCRIPT_DIR/claude-cloud.sh" "$HOME/claude-cloud"
cp "$SCRIPT_DIR/claude-status.sh" "$HOME/claude-status"
chmod +x "$HOME/claude-local" "$HOME/claude-cloud" "$HOME/claude-status"

echo "✓ Scripts copied to:"
echo "  ~/claude-local"
echo "  ~/claude-cloud"
echo "  ~/claude-status"
echo ""

# Create shell functions
FUNCTIONS=$(cat <<'EOF'

# Claude Code CLI switcher functions
# Switch between local Qwen2.5-Coder and Anthropic cloud API

claude-local() {
    echo "🔄 Switching to local model..."

    # Store current API key if it exists and isn't already stored
    if [ -n "$ANTHROPIC_API_KEY" ] && [ "$ANTHROPIC_API_KEY" != "sk-local" ]; then
        export ANTHROPIC_API_KEY_BACKUP="$ANTHROPIC_API_KEY"
        echo "💾 Stored existing API key"
    fi

    # Set local configuration
    export ANTHROPIC_BASE_URL="http://unraid.clintonsteiner.com:3000/v1"
    export ANTHROPIC_API_KEY="sk-local"
    export ANTHROPIC_MODEL="qwen2.5-coder:32b-instruct-q5_K_M"

    echo "✅ Now using local Qwen2.5-Coder model"
    echo "   Run 'claude-status' to verify"
}

claude-cloud() {
    echo "🔄 Switching to Anthropic cloud API..."

    # Restore backed up API key if it exists
    if [ -n "$ANTHROPIC_API_KEY_BACKUP" ]; then
        export ANTHROPIC_API_KEY="$ANTHROPIC_API_KEY_BACKUP"
        echo "🔑 Restored original API key"
        unset ANTHROPIC_API_KEY_BACKUP
    else
        # If no backup, unset the key (will use ~/.claude/config.json)
        unset ANTHROPIC_API_KEY
    fi

    # Unset local-specific variables
    unset ANTHROPIC_BASE_URL
    unset ANTHROPIC_MODEL

    echo "✅ Now using Anthropic cloud API"
    echo "   Run 'claude-status' to verify"
}

claude-status() {
    if [ -n "$ANTHROPIC_BASE_URL" ]; then
        echo "📊 Mode: 🏠 LOCAL (Qwen2.5-Coder)"
        echo "   Base URL: $ANTHROPIC_BASE_URL"
        echo "   Model: ${ANTHROPIC_MODEL:-default}"
        if [ -n "$ANTHROPIC_API_KEY_BACKUP" ]; then
            echo "   💾 Original API key stored (will restore on cloud switch)"
        fi
    else
        echo "📊 Mode: ☁️  CLOUD (Anthropic API)"
        echo "   Using: Claude Sonnet/Opus"
        if [ -n "$ANTHROPIC_API_KEY" ]; then
            echo "   🔑 API key: ${ANTHROPIC_API_KEY:0:10}...${ANTHROPIC_API_KEY: -4}"
        else
            echo "   🔑 API key: (from ~/.claude/config.json)"
        fi
    fi
}

# Aliases for convenience
alias cl="claude-local"
alias cc="claude-cloud"
alias cs="claude-status"
EOF
)

# Check if functions already exist
if grep -q "claude-local()" "$RC_FILE" 2>/dev/null; then
    echo "⚠️  Functions already exist in $RC_FILE"
    read -p "Do you want to update them? [y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Skipping function installation"
        echo ""
        echo "✅ Setup complete!"
        exit 0
    fi

    # Remove old functions
    echo "Removing old functions..."
    # This is a simple approach - in production you'd want more sophisticated parsing
    sed -i.bak '/# Claude Code CLI switcher functions/,/alias cs="claude-status"/d' "$RC_FILE"
fi

# Add functions to RC file
echo "Adding functions to $RC_FILE..."
echo "$FUNCTIONS" >> "$RC_FILE"

echo "✅ Functions added to $RC_FILE"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Setup complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Reload your shell configuration:"
echo "  source $RC_FILE"
echo ""
echo "Available commands:"
echo "  claude-local    (or 'cl') - Switch to local model"
echo "  claude-cloud    (or 'cc') - Switch to Anthropic cloud"
echo "  claude-status   (or 'cs') - Show current mode"
echo ""
echo "Example usage:"
echo "  $ claude-local"
echo "  $ claude          # Now uses local model"
echo "  $ claude-cloud"
echo "  $ claude          # Now uses Anthropic API"
echo ""
echo "🎉 Happy coding!"
