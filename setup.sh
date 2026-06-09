#!/usr/bin/env bash
set -euo pipefail

SOURCE_DIR="$(dirname "${BASH_SOURCE[0]}")"

# =========================
# SETUP
# =========================
chmod +x "$SOURCE_DIR/app/env.sh"
source "$SOURCE_DIR/app/env.sh"
source "$SOURCE_DIR/app/utils/check_conf.sh"
source "$SOURCE_DIR/app/utils/detect_os.sh"
source "$SOURCE_DIR/app/utils/detect_missing_cli.sh"
source "$SOURCE_DIR/app/utils/select_scripts.sh"
source "$SOURCE_DIR/app/src/pre_menu.sh"
source "$SOURCE_DIR/app/src/run_scripts.sh"
source "$SOURCE_DIR/app/src/save_profile.sh"
source "$SOURCE_DIR/app/src/register_alias.sh"

# =========================
# MAIN
# =========================
check_conf
pre_menu
verify_winget

declare -a selected_scripts
select_scripts_menu "$SCRIPTS_DIR" selected_scripts

run_scripts selected_scripts
save_profile selected_scripts
register_alias
