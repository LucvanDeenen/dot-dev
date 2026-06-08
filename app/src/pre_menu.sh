#!/usr/bin/env bash

pre_menu() {
  clear
  echo "# === dot-dev =========================="
  echo
  echo " [1] project"
  echo " [2] setup"
  echo
  read -rp "> Your choice: " choice
  echo

  case "$choice" in
    1)
      echo "Opening shell in: $ROOT_DIR"
      cd "$ROOT_DIR"
      git pull
      clear
      exec "${SHELL:-bash}"
      ;;
    2)
      echo "Pulling latest changes..."
      git -C "$ROOT_DIR" pull
      clear
      echo
      ;;
    *)
      echo "Invalid choice. Exiting."
      exit 1
      ;;
  esac
}
