#!/usr/bin/env bash
#
# ClipManager.sh — greenclip + rofi, Ctrl+1/Ctrl+2 actions

# 1) Paths & setup
HIST_FILE="${XDG_CACHE_HOME:-$HOME/.cache}/greenclip.history"

# Ensure cache dir + history file exist
mkdir -p "$(dirname "$HIST_FILE")"
touch    "$HIST_FILE"

# 2) Optional: launch daemon if you want live collecting
if ! pgrep -x greenclip >/dev/null; then
  greenclip daemon &
fi

# 3) Show history in rofi, binding Ctrl+1/Ctrl+2
entry=$(
  greenclip print |
  rofi -dmenu -i -p "Greenclip" \
       -kb-custom-1 "Control+1" \
       -kb-custom-2 "Control+2"
)
code=$?

# 4) Handle the keys
case $code in
  10)  # Ctrl+1 → delete this entry
    greenclip delete "$entry"
    ;;
  11)  # Ctrl+2 → stop daemon, clear history, restart
    pkill greenclip
    greenclip clear
    greenclip daemon &
    ;;
  0)   # Enter → copy to clipboard
    printf '%s' "$entry" | xclip -selection clipboard
    ;;
  *)   # Esc/timeout/etc → nothing
    ;;
esac
