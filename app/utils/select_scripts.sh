#!/usr/bin/env bash
set -euo pipefail

# ==========================================================
# Function: select_scripts_menu
# Description: Simple numeric selection menu (cross-platform)
# ==========================================================
select_scripts_menu() {
  local scripts_dir="$1"
  local -n result_array=$2

  chmod +x "$scripts_dir"/*.sh 2>/dev/null || true
  mapfile -t scripts < <(find "$scripts_dir" -maxdepth 1 -type f -name "*.sh" -exec basename {} \; | sort)

  if [ ${#scripts[@]} -eq 0 ]; then
    echo "No setup scripts found in $scripts_dir"
    return 1
  fi

  echo "# === Scripts ========================="
  echo
  echo "Select scripts to run by typing their numbers separated by spaces."
  echo "Type 0 to select all scripts."
  echo

  # Display menu
  echo " [0] all"
  for i in "${!scripts[@]}"; do
    printf " [%d] %s\n" $((i+1)) "${scripts[$i]}"
  done
  echo

  # Read user input
  read -rp "> Your choice: " -a selections

  # Handle empty input
  if [ ${#selections[@]} -eq 0 ]; then
    echo "No selection made. Exiting."
    return 1
  fi

  result_array=()
  # If 0 is in selections → all
  if [[ " ${selections[*]} " =~ " 0 " ]]; then
    result_array=("${scripts[@]}")
  else
    for idx in "${selections[@]}"; do
      if [[ "$idx" =~ ^[0-9]+$ ]] && ((idx >= 1 && idx <= ${#scripts[@]})); then
        result_array+=("${scripts[$((idx-1))]}")
      else
        echo "Invalid selection: $idx"
      fi
    done
  fi

  echo
  echo "Selected scripts:"
  for s in "${result_array[@]}"; do
    echo " - $s"
  done
  echo
}
