#!/usr/bin/env bash
set -euo pipefail

# 1) apps to check: WM_CLASS → launch cmd
declare -A apps=(
  [cantata]=cantata
  [autokey-qt]=autokey-qt
  [Notion]=notion-app
  [notion-calendar-electron]=notion-calendar-electron
)

# 2) grab all running WM_CLASSes once (strip off instance)
mapfile -t running_classes < <(
  wmctrl -lx |
    awk '{print $3}' |
    sed 's/^[^.]*\.//' |
    sort -u
)

# 3) for each desired class, launch if missing
for class in "${!apps[@]}"; do
  if ! printf '%s\n' "${running_classes[@]}" | grep -xq "$class"; then
    echo "↪ launching ${apps[$class]}"
    # Use nohup+& so it won’t tie up this script
    nohup "${apps[$class]}" >/dev/null 2>&1 &
  else
    echo "✔ $class already running"
  fi
done
