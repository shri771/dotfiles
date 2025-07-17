#!/bin/bash

# Variables
rofi_theme="$HOME/.config/rofi/config-clipboard.rasi"
msg='👀 **note**  CTRL DEL = cliphist del (entry)   or   ALT DEL - cliphist wipe (all)'
# Actions:
# CTRL Del to delete an entry
# ALT Del to wipe clipboard contents

# Check if rofi is already running
if pidof rofi > /dev/null; then
  pkill rofi
fi

while true; do
    result=$(cliphist list | sed 's/^[0-9]\+\s\+//' | rofi -i -dmenu \
        -kb-custom-1 "Control-Delete" \
        -kb-custom-2 "Alt-Delete" )

    exit_code=$?

    case "$exit_code" in
        1) # Cancel
            exit
            ;;
        0) # OK
            if [ -z "$result" ]; then
                continue
            fi
            cliphist list | grep -F "$result" | head -n 1 | cliphist decode | wl-copy
            exit
            ;;
        10) # Custom 1 (Delete)
            if [ -z "$result" ]; then
                continue
            fi
            cliphist list | grep -F "$result" | head -n 1 | cliphist delete
            ;;
        11) # Custom 2 (Wipe)
            cliphist wipe
            ;;
    esac
done