#!/usr/bin/env bash

check_conf() {
  if [ -d "$DOT_CONF_DIR" ] && [ -n "$(ls -A "$DOT_CONF_DIR" 2>/dev/null)" ]; then
    return 0
  fi

  echo "# === dot-conf ========================="
  echo
  if [ ! -d "$DOT_CONF_DIR" ]; then
    echo " dot-conf directory not found at:"
  else
    echo " dot-conf directory is empty at:"
  fi
  echo "   $DOT_CONF_DIR"
  echo

  read -rp " Is this the correct path? [y/N]: " path_confirm
  echo

  if [[ ! "$path_confirm" =~ ^[Yy]$ ]]; then
    echo " Set DOT_CONF_DIR to your dot-conf location and re-run:"
    echo "   DOT_CONF_DIR=/path/to/dot-conf bash setup.sh"
    echo
    exit 1
  fi

  read -rp " Initialize dot-conf template at this path? [Y/n]: " init_confirm
  init_confirm="${init_confirm:-y}"
  echo

  if [[ ! "$init_confirm" =~ ^[Yy]$ ]]; then
    echo " Aborting. Clone or create your dot-conf repo at $DOT_CONF_DIR first."
    echo
    exit 1
  fi

  local template_dir="$ROOT_DIR/conf"

  if [ ! -d "$template_dir" ]; then
    echo " Template not found at: $template_dir"
    exit 1
  fi

  mkdir -p "$DOT_CONF_DIR"
  cp -r "$template_dir/." "$DOT_CONF_DIR/"

  echo " Template initialized at $DOT_CONF_DIR"
  echo " Update the placeholder values in your dot-conf before continuing."
  echo
  read -rp " Press Enter to continue with setup..."
  echo
}
