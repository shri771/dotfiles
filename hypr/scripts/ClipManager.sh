#!/bin/bash
# Clipboard Manager using cliphist, rofi, wl-copy, and wtype (for auto-paste)

# Variables
rofi_theme="$HOME/.config/rofi/config-clipboard.rasi"
msg='👀 **note**  CTRL DEL = cliphist del (entry)   or   ALT DEL - cliphist wipe (all)'

# Ensure dependencies are installed
if ! command -v cliphist &>/dev/null || ! command -v rofi &>/dev/null || ! command -v wl-copy &>/dev/null || ! command -v wtype &>/dev/null; then
    echo "Error: Required dependencies (cliphist, rofi, wl-copy, wtype) are missing."
    exit 1
fi

# Kill existing rofi instance if running
if pidof rofi > /dev/null; then
  pkill rofi
fi

while true; do
    result=$(
        rofi -i -dmenu \
            -kb-custom-1 "Control-Delete" \
            -kb-custom-2 "Alt-Delete" \
            -config "$rofi_theme" < <(cliphist list) \
            -mesg "$msg"
    )

    case "$?" in
        1) exit ;;  # User pressed Escape, exit script
        0)  
            if [[ -n "$result" ]]; then
                # Decode selection and copy it to clipboard
                cliphist decode <<< "$result" | wl-copy
                sleep 0.1  # Small delay to ensure clipboard is set
                wtype -M control v -m control  # Simulate Ctrl+V (paste)
                exit
            fi
            ;;
        10)  
            cliphist delete <<< "$result" ;;
        11)  
            cliphist wipe ;;
    esac
done
