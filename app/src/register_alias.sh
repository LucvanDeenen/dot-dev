#!/usr/bin/env bash

register_alias() {
  local dot_alias_file="$HOME/.cli/alias/dot.sh"
  mkdir -p "$(dirname "$dot_alias_file")"

  {
    echo "# dot-dev"
    echo "alias dot-dev=\"bash $ROOT_DIR/setup.sh\""
  } > "$dot_alias_file"

  echo " > Installed 'dot-dev' command -> $ROOT_DIR/setup.sh"
  echo " > Run 'sr' to reload aliases."
  echo
  echo "===== .active =========================="
  cat "$ACTIVE_FILE"
  echo "========================================"
}
