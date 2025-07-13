#!/usr/bin/env fish

# Flip between QWERTY and Dvorak
set current (hyprctl keyword input:kb_variant | grep -oP 'dvorak.*')

if test "$current"
  hyprctl keyword input:kb_variant ""
  set MSG "Switched to QWERTY"
else
  hyprctl keyword input:kb_variant "dvorak"
  set MSG "Switched to Dvorak"
end

hyprctl reload
naughty -u normal -t 2000 --text="$MSG"

