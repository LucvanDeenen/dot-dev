#!/usr/bin/env bash
set -euo pipefail

# =========================
# SETUP
# =========================
source "$(dirname "${BASH_SOURCE[0]}")/../env.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../utils/install_cli.sh"

# =========================
# CONFIG
# =========================
GIT_FOLDER="$CONFIG_FOLDER/git"
DEST_DIR="$HOME"

# =========================
# FUNCTIONS
# =========================
setup_dotnet() {
  winget install Microsoft.DotNet.SDK.10
}

setup_nuget() {
  setup_cli_from_tar "nuget" "$CONFIG_FOLDER/nuget/nuget.tar.gz" "$HOME/bin"

  echo
  echo "# UPDATING #"
  nuget update -self
}

setup_git() {
  echo "Setting up GIT..."
  echo "Source: '$GIT_FOLDER'"
  echo "Destination: '$DEST_DIR'"

  # Check if Git is installed
  if ! command -v git &>/dev/null; then
    echo "Git is not installed."
    default_confirm="y"
    read -rp "Would you like to install Git now? [y/N]: " confirm
    confirm="${confirm:-$default_confirm}" 
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
      install_git
    else
      echo "Git installation skipped. Aborting setup."
      exit 1
    fi
  else
    echo "Git is already installed: $(git --version)"
  fi

  # Ensure source exists
  if [ ! -d "$GIT_FOLDER" ]; then
    echo "Git config folder not found: $GIT_FOLDER"
    exit 1
  fi

  # Copy all files/folders from $GIT_FOLDER into home
  cp -a "$GIT_FOLDER/." "$DEST_DIR/"
}

install_git() {
  case "$(uname -s)" in
    Darwin*)
      echo "Installing Git via Homebrew..."
      if ! command -v brew &>/dev/null; then
        echo "Homebrew not found. Installing Homebrew first..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      fi
      brew install git
      ;;
    Linux*)
      if command -v apt &>/dev/null; then
        echo "Installing Git via apt..."
        sudo apt update && sudo apt install -y git
      elif command -v dnf &>/dev/null; then
        echo "Installing Git via dnf..."
        sudo dnf install -y git
      elif command -v pacman &>/dev/null; then
        echo "Installing Git via pacman..."
        sudo pacman -S --noconfirm git
      else
        echo "Could not detect supported package manager. Please install Git manually."
        exit 1
      fi
      ;;
    CYGWIN*|MINGW*|MSYS*)
      echo "Windows detected."
      winget install --id Git.Git -e --source winget
      exit 1
      ;;
    *)
      echo "Unknown OS — please install Git manually."
      exit 1
      ;;
  esac
}

# =========================
# MAIN LOGIC
# =========================
echo "Setting up development..."
setup_git

case "$(uname -s)" in
  CYGWIN*|MINGW*|MSYS*)
    echo "Detected Windows environment."
    setup_nuget
    setup_dotnet
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
