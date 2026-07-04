#!/usr/bin/env bash
set -euo pipefail

# ==========================================================
# Function: verify_winget
# Description: Install winget on windows machines
# ==========================================================
verify_winget() {
  os_name=$(detect_os)

  # Only run on Windows
  if [[ "$os_name" != "windows" ]]; then
    return 0
  fi

  if command -v winget >/dev/null 2>&1; then
    return 0
  fi

  powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "
    \$pkg = Get-AppxPackage -Name Microsoft.DesktopAppInstaller -ErrorAction SilentlyContinue
    if (-not \$pkg) {
      Write-Host 'Installing App Installer from Microsoft Store...'
      Start-Process 'ms-windows-store://pdp/?ProductId=9NBLGGH4NNS1'
      Write-Host 'Please install App Installer manually if prompted, then re-run setup.'
    } else {
      Write-Host 'App Installer already installed but winget not in PATH.'
    }
  "

  echo
  echo "Please restart your terminal after installation and re-run setup.sh."
  exit 1
}
