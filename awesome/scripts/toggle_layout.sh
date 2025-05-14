#!/usr/bin/env bash
# ~/bin/toggle_layout.sh

# detect current XKB variant (empty = plain US)
current=$(setxkbmap -query | awk '/variant/{print $2}')

if [ "$current" = "dvp" ]; then
  # switch back to plain US
  setxkbmap -layout us
  layout_name="US QWERTY"
  layout_icon="⌨️🇺🇸"
else
  # switch to Dvorak Programmer
  setxkbmap -layout us -variant dvp
  layout_name="Dvorak Programmer"
  layout_icon="⌨️🔧"
fi

# send desktop notification
# -i keyboard: try the “keyboard” icon, fallback to none if not available
# the notification summary is the layout name; body shows the icon
notify-send \
  --urgency=low \
  --app-name="Layout Toggle" \
  --icon=keyboard \
  "$layout_name" \
  "$layout_icon"
