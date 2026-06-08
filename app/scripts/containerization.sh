#!/usr/bin/env bash
set -euo pipefail

# =========================
# SETUP
# =========================
source "$(dirname "${BASH_SOURCE[0]}")/../../env.sh"

# =========================
# FUNCTIONS
# =========================
install_docker_windows() {
  echo "Checking for Docker installation..."
  if command -v docker >/dev/null 2>&1; then
    echo "Docker is already installed."
    return 0
  else
    echo "Docker is not found on this system."
    read -rp "Would you like to install Docker Desktop now? [Y/n]: " confirm
    confirm="${confirm:-Y}"
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
      echo "Attempting to install Docker Desktop with winget..."
      powershell.exe -Command "winget install -e --id Docker.DockerDesktop"
      echo "Once installation is complete, restart your terminal and rerun this script."
      exit 0
    else
      echo "Docker Desktop installation skipped. CLI setup cannot continue."
      exit 1
    fi
  fi
}

# =========================
# MAIN LOGIC
# =========================
echo "Setting up Docker..."
echo 

case "$(uname -s)" in
  CYGWIN*|MINGW*|MSYS*)
    echo "Detected Windows environment."
    install_docker_windows
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
    ;;
esac