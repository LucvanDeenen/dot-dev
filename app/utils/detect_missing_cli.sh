#!/usr/bin/env bash
set -euo pipefail

# ==========================================================
# Function: verify_command_installed
# Description: Determines the missing CLI tool
# ==========================================================
verify_command_installed() {
    local cmd="$1"
    local install_url="$2"
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "$cmd is not installed."
        echo "Please follow the instructions here to install it:"
        echo "$install_url"
        return 0
    else
        echo "$cmd is installed."
        return 0
    fi
}