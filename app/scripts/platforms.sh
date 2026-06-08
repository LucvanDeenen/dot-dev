#!/usr/bin/env bash
set -euo pipefail

# =========================
# SETUP
# =========================
source "$(dirname "${BASH_SOURCE[0]}")/../../env.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../utils/install_cli.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../utils/detect_missing_cli.sh"

# =========================
# CONFIG
# =========================
CLI_FOLDER="$CONFIG_FOLDER/aws"
DEST_DIR="$HOME"

# =========================
# FUNCTIONS
# =========================
setup_ocp() {
  setup_cli_from_tar "oc" "$CONFIG_FOLDER/ocp/oc.tar.gz" "$HOME/bin"
}

# =========================
# MAIN LOGIC
# =========================
echo "Setting up openshift cli tools..."

case "$(uname -s)" in
  CYGWIN*|MINGW*|MSYS*)
    echo "Detected Windows environment."
    setup_ocp
    ;;
  Linux*)
    echo "Detected Linux environment."
    echo "No installation provided."
    ;;
  Darwin*)
    echo "Detected macOS environment."
    echo "No installation provided."
    ;;
  *)
    echo "Unknown OS detected. Proceeding without Git Bash check."
    echo "No installation provided."
    ;;
esac


echo "Setting up AWS Config..."
echo "Source: '$CLI_FOLDER'"
echo "Destination: '$DEST_DIR'"

# Ensure source exists
if [ ! -d "$CLI_FOLDER" ]; then
  echo "CLI config folder not found: $CLI_FOLDER"
  exit 1
fi

# Copy all files/folders from $CLI_FOLDER into home
cp -a "$CLI_FOLDER/." "$DEST_DIR/"