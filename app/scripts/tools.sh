#!/usr/bin/env bash
set -euo pipefail

# =========================
# SETUP
# =========================
source "$(dirname "${BASH_SOURCE[0]}")/../../env.sh"

# =========================
# CONFIG
# =========================
SHELF_REPO="LucvanDeenen/shelf"
INSTALLER_NAME="Shelf-Installer.exe"
TEMP_DIR="${TEMP:-/tmp}"
INSTALL_PATH="$TEMP_DIR/$INSTALLER_NAME"
SHELF_COMMON_PATHS=(
  "$HOME/AppData/Local/Programs/Shelf/Shelf.exe"
  "$HOME/AppData/Local/Shelf/Shelf.exe"
  "C:/Program Files/Shelf/Shelf.exe"
  "C:/Program Files (x86)/Shelf/Shelf.exe"
)

# =========================
# FUNCTIONS
# =========================
fetch_latest_release_info() {
  local repo=$1
  local asset_name=$2

  echo "Fetching latest release for $repo..." >&2

  # Get latest release info from GitHub API
  local release_info
  release_info=$(curl -s "https://api.github.com/repos/$repo/releases/latest")

  # Check if the API response is valid (contains 'tag_name')
  if ! echo "$release_info" | grep -q "tag_name"; then
    echo "Error: Failed to fetch from GitHub API. Response: $release_info" >&2
    return 1
  fi

  # Extract tag name (version)
  local version
  version=$(echo "$release_info" | grep -o '"tag_name": "[^"]*"' | head -1 | cut -d'"' -f4)

  # Extract download URL for the specified asset
  local download_url
  download_url=$(echo "$release_info" | grep -o '"browser_download_url": "[^"]*'"$asset_name"'"' | head -1 | cut -d'"' -f4)

  if [ -z "$download_url" ]; then
    echo "Error: Could not find $asset_name in latest release" >&2
    return 1
  fi

  if [ -z "$version" ]; then
    echo "Error: Could not extract version from release" >&2
    return 1
  fi

  echo "$download_url|$version"
}

find_installed_shelf() {
  for path in "${SHELF_COMMON_PATHS[@]}"; do
    if [ -f "$path" ]; then
      echo "$path"
      return 0
    fi
  done
  return 1
}

get_installed_version() {
  local exe_path=$1

  # Convert Unix path to Windows path for PowerShell
  local win_path
  win_path=$(cygpath -w "$exe_path" 2>/dev/null || echo "$exe_path")

  # Try to use PowerShell to get file version
  if command -v powershell &> /dev/null; then
    local version
    version=$(powershell -Command "[System.Diagnostics.FileVersionInfo]::GetVersionInfo('$win_path').FileVersion" 2>/dev/null | tr -d '\r')
    if [ -n "$version" ] && [ "$version" != "" ]; then
      echo "$version"
    else
      echo "unknown"
    fi
  else
    echo "unknown"
  fi
}

compare_versions() {
  local installed=$1
  local latest=$2

  # Remove 'v' prefix if present
  installed="${installed#v}"
  latest="${latest#v}"

  # Simple version comparison (assumes semantic versioning)
  if [ "$installed" = "$latest" ]; then
    return 0  # Same version
  fi

  # Compare versions by converting to comparable format
  local installed_first=$(echo "$installed" | cut -d'.' -f1)
  local latest_first=$(echo "$latest" | cut -d'.' -f1)

  if [ "$installed_first" -lt "$latest_first" ]; then
    return 1  # Installed is older
  elif [ "$installed_first" -gt "$latest_first" ]; then
    return 2  # Installed is newer
  fi

  # If major versions are the same, compare minor
  local installed_minor=$(echo "$installed" | cut -d'.' -f2 2>/dev/null || echo "0")
  local latest_minor=$(echo "$latest" | cut -d'.' -f2 2>/dev/null || echo "0")

  if [ "$installed_minor" -lt "$latest_minor" ]; then
    return 1  # Installed is older
  elif [ "$installed_minor" -gt "$latest_minor" ]; then
    return 2  # Installed is newer
  fi

  return 0  # Versions are the same
}

download_installer() {
  local url=$1
  local destination=$2

  echo "Downloading $INSTALLER_NAME..."

  if ! curl -sL -o "$destination" "$url"; then
    echo "Error: Failed to download installer"
    return 1
  fi

  echo "Downloaded to: $destination"
}

run_installer() {
  local installer_path=$1

  if [ ! -f "$installer_path" ]; then
    echo "Error: Installer not found at $installer_path"
    return 1
  fi

  echo "Running installer..."
  if command -v powershell &> /dev/null; then
    powershell -Command "Start-Process -FilePath '$installer_path' -Wait"
  else
    echo "Error: PowerShell not found. Please run the installer manually:"
    echo "  $installer_path"
    return 1
  fi
}

# =========================
# VSCODE
# =========================
setup_vscode() {
  echo "Checking VSCode installation..."

  if command -v code &>/dev/null; then
    echo "✓ VSCode is already installed: $(code --version | head -1)"
    echo
    return 0
  fi

  echo "VSCode is not installed."
  read -rp "Would you like to install VSCode now? [Y/n]: " confirm
  confirm="${confirm:-y}"
  if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "VSCode installation skipped."
    echo
    return 0
  fi

  case "$(uname -s)" in
    CYGWIN*|MINGW*|MSYS*)
      echo "Installing VSCode via winget..."
      winget install --id Microsoft.VisualStudioCode -e --source winget
      ;;
    Darwin*)
      if command -v brew &>/dev/null; then
        echo "Installing VSCode via Homebrew..."
        brew install --cask visual-studio-code
      else
        echo "Homebrew not found. Please install VSCode manually from https://code.visualstudio.com/"
        return 1
      fi
      ;;
    Linux*)
      if command -v snap &>/dev/null; then
        echo "Installing VSCode via snap..."
        sudo snap install --classic code
      elif command -v apt &>/dev/null; then
        echo "Installing VSCode via apt..."
        wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /tmp/packages.microsoft.gpg
        sudo install -o root -g root -m 644 /tmp/packages.microsoft.gpg /etc/apt/trusted.gpg.d/
        echo "deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list
        sudo apt update && sudo apt install -y code
      else
        echo "Could not detect supported package manager. Please install VSCode manually from https://code.visualstudio.com/"
        return 1
      fi
      ;;
    *)
      echo "Unknown OS — please install VSCode manually from https://code.visualstudio.com/"
      return 1
      ;;
  esac

  echo "✓ VSCode installation complete!"
  echo
}

# =========================
# MAIN LOGIC
# =========================
setup_vscode

echo "Checking Shelf installation..."
echo

# Check if Shelf is already installed
installed_exe=$(find_installed_shelf) || installed_exe=""

if [ -n "$installed_exe" ]; then
  echo "✓ Shelf is already installed at:"
  echo "  $installed_exe"
  installed_version=$(get_installed_version "$installed_exe")
  echo "  Version: $installed_version"
  echo
else
  echo "Shelf is not installed"
  echo
fi

# Fetch the latest release info
if ! release_info=$(fetch_latest_release_info "$SHELF_REPO" "$INSTALLER_NAME"); then
  echo "Failed to fetch latest release"
  exit 1
fi

download_url=$(echo "$release_info" | cut -d'|' -f1)
latest_version=$(echo "$release_info" | cut -d'|' -f2)

echo "Latest version: $latest_version"
echo

# Check if we need to update
if [ -n "$installed_exe" ]; then
  if [ "$installed_version" = "unknown" ]; then
    echo "⚠ Could not determine installed version"
    read -rp "Do you want to proceed with installation? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      echo "Installation skipped."
      exit 0
    fi
  else
    compare_versions "$installed_version" "$latest_version"
    version_cmp=$?

    if [ $version_cmp -eq 0 ]; then
      echo "✓ You already have the latest version installed!"
      exit 0
    elif [ $version_cmp -eq 2 ]; then
      echo "⚠ Your installed version is newer than the latest release"
      exit 0
    else
      echo "↻ Updating from $installed_version to $latest_version..."
      echo
    fi
  fi
else
  echo "Installing Shelf..."
  echo
fi

# Download the installer
if ! download_installer "$download_url" "$INSTALL_PATH"; then
  echo "Failed to download installer"
  exit 1
fi

echo

# Run the installer
if ! run_installer "$INSTALL_PATH"; then
  echo "Failed to run installer"
  exit 1
fi

echo
echo "✓ Shelf installation complete!"
