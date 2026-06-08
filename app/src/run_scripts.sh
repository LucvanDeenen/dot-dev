#!/usr/bin/env bash

run_scripts() {
  local -n _scripts=$1

  clear
  for s in "${_scripts[@]}"; do
    local script_path="$SCRIPTS_DIR/$s"
    if [ -x "$script_path" ]; then
      echo "# === $s ========================="
      bash "$script_path" || true
      echo
      read -rp "Press Enter to continue..."
      echo
      clear
    else
      echo " Skipping $s (not executable)"
      echo
    fi
  done
}
