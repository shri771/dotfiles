#!/bin/bash
# Filtered Clipboard Manager for Wayland
# 💫 https://github.com/JaKooLit 💫

# Variables
rofi_theme="$HOME/.config/rofi/config-clipboard.rasi"

# Filter out unwanted patterns
FILTERED_HISTORY=$(
    cliphist list | \
    grep -vE '^[0-9]+[[:space:]]+(#!|❯|echo|cliphist|wl-copy|sleep|rofi)'
)

# Show selection menu
SELECTION=$(
    echo "$FILTERED_HISTORY" | \
    rofi -dmenu -i -config "$rofi_theme" \
        -kb-custom-1 "Control-Delete" \
        -kb-custom-2 "Alt-Delete"
)

# Handle selection
case $? in
    0)
        if [[ -n "$SELECTION" ]]; then
            CONTENT=$(cliphist decode <<< "$SELECTION")
            echo -n "$CONTENT" | wl-copy
        fi
        ;;
    10)
        [[ -n "$SELECTION" ]] && cliphist delete <<< "$SELECTION"
        ;;
    11)
        cliphist wipe
        ;;
esac
