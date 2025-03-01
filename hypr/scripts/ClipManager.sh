#!/bin/bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# Clipboard Manager using cliphist, rofi, and wl-copy.

# Variables
rofi_theme="$HOME/.config/rofi/config-clipboard.rasi"

# Check if rofi is already running
if pidof rofi > /dev/null; then
  pkill rofi
fi

while true; do
    result=$(
        rofi -i -dmenu \
            -kb-custom-1 "Control-Delete" \
            -kb-custom-2 "Alt-Delete" \
            -config "$rofi_theme" < <(cliphist list)
    )

    exit_code=$?

    if [[ $exit_code -eq 1 ]]; then
        exit
    elif [[ $exit_code -eq 0 && -n "$result" ]]; then
        decoded_text=$(cliphist decode <<<"$result")

        if [[ -n "$decoded_text" ]]; then
            printf "%s" "$decoded_text" | wl-copy
            printf "%s" "$decoded_text" | wl-copy -p
            sleep 0.2  # Allow clipboard update
        else
            printf "Failed to decode clipboard entry\n" >&2
        fi
        exit
    elif [[ $exit_code -eq 10 && -n "$result" ]]; then
        cliphist delete <<<"$result"
    elif [[ $exit_code -eq 11 ]]; then
        cliphist wipe
    fi
done
