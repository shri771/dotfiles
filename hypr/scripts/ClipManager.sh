#!/bin/bash
# Clipboard Manager using cliphist, rofi, and wl-copy
# 💫 https://github.com/JaKooLit 💫

# Variables
rofi_theme="$HOME/.config/rofi/config-clipboard.rasi"

# Check if rofi is already running and kill it if necessary
if pidof rofi >/dev/null; then
  pkill rofi
fi

while true; do
    result=$(
        cliphist list | rofi -i -dmenu \
            -kb-custom-1 "Control-Delete" \
            -kb-custom-2 "Alt-Delete" \
            -config "$rofi_theme"
    )

    case "$?" in
        1) exit ;;  # Exit on cancel
        0)
            if [[ -n "$result" ]]; then
                cliphist decode <<<"$result" | wl-copy
                wl-paste >/dev/null  # Ensure the clipboard updates correctly
                exit
            fi
            ;;
        10)
            [[ -n "$result" ]] && cliphist delete <<<"$result"
            ;;
        11)
            cliphist wipe
            ;;
    esac
done
