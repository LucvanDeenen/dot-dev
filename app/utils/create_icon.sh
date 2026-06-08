set_folder_icon() {
  local icon_name="$1"
  local target_folder="$2"

  # Base directory where icons live (Windows path via cygpath)
  local win_home
  win_home="$(cygpath -w "$HOME")"
  local icons_dir="${win_home}\\repos\\dot-dev\\app\\icons"

  # Ensure .ico extension
  [[ "$icon_name" != *.ico ]] && icon_name="${icon_name}.ico"

  local icon_path="${icons_dir}\\${icon_name}"
  local desktop_ini="${target_folder}/desktop.ini"

  # Create desktop.ini with Windows line endings
  cat > "$desktop_ini" <<EOF
[.ShellClassInfo]
IconResource=${icon_path},0
[ViewState]
Mode=
Vid=
FolderType=Generic
EOF

  # Apply Windows attributes
  attrib +h +s "$(cygpath -w "$desktop_ini")"
  attrib +s "$(cygpath -w "$target_folder")"

  echo "created icon $desktop_ini"
}