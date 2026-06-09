#!/usr/bin/env bash

# =========================
# GLOBAL DOTFILES CONFIG
# =========================
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPTS_DIR="$ROOT_DIR/app/scripts"
ACTIVE_FILE="$HOME/.dot-dev"
DOT_CONF_DIR="${DOT_CONF_DIR:-$HOME/repos/dot-conf}"
CONFIG_FOLDER="$DOT_CONF_DIR"
