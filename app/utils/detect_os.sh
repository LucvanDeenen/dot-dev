#!/usr/bin/env bash
set -euo pipefail

# ==========================================================
# Function: detect_os
# Description: Determines the current OS
# ==========================================================
detect_os() {
  case "$(uname -s)" in
    Linux*)  echo "linux" ;;
    Darwin*) echo "macos" ;;
    CYGWIN*|MINGW*|MSYS*) echo "windows" ;;
    *)       echo "unknown" ;;
  esac
}
