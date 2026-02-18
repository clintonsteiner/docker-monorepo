#!/bin/bash
set -euo pipefail

# Jenkins Plugin Update Manager
# Checks for plugin updates and creates a summary

PLUGINS_FILE="./plugins.txt"
TEMP_DIR=$(mktemp -d)
trap 'rm -rf $TEMP_DIR' EXIT

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║          Jenkins Plugin Update Checker                         ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

if [ ! -f "$PLUGINS_FILE" ]; then
  echo " $PLUGINS_FILE not found"
  exit 1
fi

echo "Current plugins: $(wc -l < $PLUGINS_FILE | xargs) installed"
echo "Checking for updates..."
echo ""

# Fetch latest plugin versions from Jenkins update center
UPDATES_FOUND=0

while IFS=: read -r plugin_name version; do
  plugin_name=$(echo "$plugin_name" | xargs)
  version=$(echo "$version" | xargs)

  if [ -z "$plugin_name" ] || [ -z "$version" ]; then
    continue
  fi

  # Check Jenkins plugin API for latest version
  echo -n "  $plugin_name... "

  if latest=$(curl -s "https://plugins.jenkins.io/api/plugin/$plugin_name" 2>/dev/null | grep -o '"version":"[^"]*"' | head -1 | cut -d'"' -f4); then
    if [ -n "$latest" ] && [ "$latest" != "$version" ]; then
      echo "⬆️  $version → $latest"
      ((UPDATES_FOUND++))
    else
      echo ""
    fi
  else
    echo " (couldn't check)"
  fi
done < "$PLUGINS_FILE"

echo ""
echo "Summary:"
echo "  Total plugins: $(wc -l < $PLUGINS_FILE | xargs)"
echo "  Updates available: $UPDATES_FOUND"
echo ""

if [ $UPDATES_FOUND -gt 0 ]; then
  echo " Tip: Use Jenkins Update Manager UI or update plugins.txt manually"
  echo "   Then rebuild the Docker image: make build-jenkinsapi"
  exit 1
else
  echo " All plugins are up to date!"
  exit 0
fi
