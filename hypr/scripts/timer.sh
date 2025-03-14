#!/bin/bash
# Clipboard Manager using cliphist and rofi

# Variables
rofi_theme="$HOME/.config/rofi/config-clipboard.rasi"

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
    if [ $exit_code -eq 1 ]; then
        exit
    elif [ $exit_code -eq 0 ] && [ -n "$result" ]; then
        decoded_text=$(cliphist decode <<< "$result")
        if [ -n "$decoded_text" ]; then
            # Use only cliphist to store the clipboard content
            printf "%s" "$decoded_text" | cliphist store
            sleep 0.5
            # Debug: check with wl-paste to see if clipboard holds the data
            current=$(wl-paste)
            if [ "$current" = "$decoded_text" ]; then
                echo "Clipboard updated successfully."
            else
                echo "Clipboard update failed. Current clipboard: $current" >&2
            fi
        else
            echo "Failed to decode clipboard entry" >&2
        fi
        exit
    elif [ $exit_code -eq 10 ] && [ -n "$result" ]; then
        cliphist delete <<< "$result"
    elif [ $exit_code -eq 11 ]; then
        cliphist wipe
    fi
done
