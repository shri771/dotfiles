#!/bin/bash
# 📋 Clipboard Manager for AwesomeWM (X11)
# Requires: rofi, xclip or xsel, greenclip (optional for history)

# Theme for rofi clipboard menu
rofi_theme="$HOME/.config/rofi/config-clipboard.rasi"

# Check if rofi is already running
pidof rofi >/dev/null && pkill rofi

# Use greenclip for history (can replace with other source if desired)
HISTORY=$(greenclip print | grep -vE '^(#!|❯|echo|greenclip|sleep|rofi)')

while true; do
    result=$(echo "$HISTORY" | rofi -dmenu -i \
        -kb-custom-1 "Control-Delete" \
        -kb-custom-2 "Alt-Delete" \
        -config "$rofi_theme")

    case "$?" in
        0)
            [[ -n "$result" ]] && echo -n "$result" | xclip -selection clipboard
            exit
            ;;
        1)
            exit
            ;;
        10)
            # Delete the selected entry from greenclip history if it exists.
            if [[ -n "$result" ]] && [ -f ~/.local/share/greenclip.history ]; then
                grep -vxF "$result" ~/.local/share/greenclip.history > ~/.local/share/greenclip.history.tmp && \
                mv ~/.local/share/greenclip.history.tmp ~/.local/share/greenclip.history
            fi
            ;;
        11)
            > ~/.local/share/greenclip.history
            ;;
    esac
done
