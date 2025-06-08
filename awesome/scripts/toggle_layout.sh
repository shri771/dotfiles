#!/usr/bin/env bash
# ~/bin/toggle_layout.sh

# detect current XKB variant (empty = plain US)
current=$(setxkbmap -query | awk '/variant/{print $2}')

if [ "$current" = "dvp" ]; then
  # switch back to plain US
  setxkbmap -layout us
  layout_name="QWERTY "
  layout_icon=" "
else
  # switch to Dvorak Programmer
  setxkbmap -layout us -variant dvp
  layout_name="Dvorak "
  layout_icon=" "
fi

# send desktop notification
notify-send \
  --urgency=low \
  --app-name="System" \
  --icon="$HOME/.config/awesome/icons/preferences-desktop-keyboard.svg" \
  "System  " \
  "$layout_name $layout_icon"
