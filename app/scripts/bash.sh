#!/usr/bin/env bash
set -euo pipefail

# =========================
# SETUP
# =========================
source "$(dirname "${BASH_SOURCE[0]}")/../env.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../utils/create_icon.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../utils/pin_quick_access.sh"

# =========================
# CONFIG
# =========================
CLI_FOLDER="$CONFIG_FOLDER/cli"
DEST_DIR="$HOME"

# =========================
# MAIN LOGIC
# =========================
echo "Setting up CLI..."
echo "Source: '$CLI_FOLDER'"
echo "Destination: '$DEST_DIR'"

# Ensure source exists
if [ ! -d "$CLI_FOLDER" ]; then
  echo "CLI config folder not found: $CLI_FOLDER"
  exit 1
fi

# Copy all files/folders from $CLI_FOLDER into home (excluding .bashrc)
find "$CLI_FOLDER" -maxdepth 1 -mindepth 1 ! -name '.bashrc' -exec cp -a {} "$DEST_DIR/" \;

# Ensure .bashrc sources .cli_profile
BASHRC="$HOME/.bashrc"
MARKER='source "$HOME/.cli/.cli_profile"'

touch "$BASHRC"
if ! grep -qF "$MARKER" "$BASHRC"; then
  printf '\nif [ -f "$HOME/.cli/.cli_profile" ]; then\n  source "$HOME/.cli/.cli_profile"\nfi\n' >> "$BASHRC"
  echo "Added .cli_profile source snippet to $BASHRC"
else
  echo ".cli_profile snippet already present in $BASHRC"
fi
