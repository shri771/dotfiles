#!/bin/bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# Clipboard Manager. This script uses cliphist, rofi, and wl-copy.

# Actions:
# CTRL Del to delete an entry
# ALT Del to wipe clipboard contents
# RETURN to paste the selected entry

# Check if rofi is already running and kill it if necessary
if pidof rofi > /dev/null; then
    pkill rofi
fi

while true; do
    result=$(
        cliphist list | rofi -i -dmenu \
            -kb-custom-1 "Control-Delete" \
            -kb-custom-2 "Alt-Delete" \
            -config ~/.config/rofi/config-clipboard.rasi
    )

    case "$?" in
        1)
            exit
            ;;
        0)
            if [[ -n "$result" ]]; then
                cliphist decode <<<"$result" | wl-copy
                sleep 0.1  # Allow time for clipboard update
                wl-paste | wl-copy
                exit
            fi
            ;;
        10)
            cliphist delete <<<"$result"
            ;;
        11)
            cliphist wipe
            ;;
    esac
done
