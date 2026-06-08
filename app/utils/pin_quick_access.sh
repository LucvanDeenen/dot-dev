pin_to_quick_access() {
  local folder="$1"

  local win_path
  win_path="$(cygpath -w "$folder")"

  powershell.exe -NoProfile -Command "
    \$target = (Get-Item -LiteralPath '$win_path').FullName
    \$shell = New-Object -ComObject Shell.Application
    \$quickAccess = \$shell.Namespace('shell:::{679F85CB-0220-4080-B29B-5540CC05AAB6}')

    \$alreadyPinned = \$false

    foreach (\$item in \$quickAccess.Items()) {
      try {
        if (\$item.Path -and (Get-Item -LiteralPath \$item.Path).FullName -eq \$target) {
          \$alreadyPinned = \$true
          break
        }
      } catch {}
    }

    if (-not \$alreadyPinned) {
      \$parent = Split-Path \$target
      \$name = Split-Path \$target -Leaf
      \$folderItem = \$shell.Namespace(\$parent).ParseName(\$name)

      if (\$folderItem) {
        \$folderItem.InvokeVerb('pintohome')
      }
    }
  "
}