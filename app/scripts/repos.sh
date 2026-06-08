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
WORK_FOLDER="$HOME/repos/workspace"
REPO_FOLDER="$HOME/repos"

# =========================
# MAIN LOGIC
# =========================
echo "Setting up repository structures..."

if [ ! -d "$REPO_FOLDER" ]; then
  echo "Setting up repos folder..."
  mkdir -p "$REPO_FOLDER"
else
  echo "Repos folder already exists..."
fi

if [ ! -d "$WORK_FOLDER" ]; then
  echo "Setting up work folder..."
  mkdir "$WORK_FOLDER"
else
  echo "Work folder already exists..."
fi

echo
pin_to_quick_access "$REPO_FOLDER"
set_folder_icon "git" "$REPO_FOLDER"

echo
echo "Structure:"
echo "├── $(basename "$WORK_FOLDER")/"
echo "├── $(basename "$REPO_FOLDER")/"
echo
echo "Repository structure setup complete!"