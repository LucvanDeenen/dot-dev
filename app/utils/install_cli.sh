#!/usr/bin/env bash
set -euo pipefail

# ==========================================================
# Function: setup_cli_from_tar
# Description: Installs cli tool from tar
# ==========================================================
setup_cli_from_tar() {
    local cmd="$1"
    local tar_path="$2"
    local target_dir="$3"
    local tar_name
    tar_name="$(basename "$tar_path")"
    local target_tar_path="$target_dir/$tar_name"

    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "'$cmd' command not found. Copying and extracting $tar_name to $target_dir..."

        # Ensure tar.gz exists
        if [ ! -f "$tar_path" ]; then
            echo "$tar_name not found at $tar_path"
            return 1
        fi

        # Create target directory if it doesn't exist
        mkdir -p "$target_dir"

        # Copy tar.gz to target directory
        cp "$tar_path" "$target_dir"

        # Extract tar.gz in the target directory
        tar -xzf "$target_tar_path" -C "$target_dir"
        echo "$tar_name extracted to $target_dir"

        # Remove the copied tar file
        rm "$target_tar_path"
        echo "Cleaned up copied $target_tar_path"
    else
        echo "'$cmd' command exists. No setup required."
    fi
}