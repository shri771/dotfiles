#!/bin/bash

# Variables
rofi_theme="$HOME/.config/rofi/config-clipboard.rasi"
msg='👀 **note**  CTRL+Del = delete entry   |   ALT+Del = wipe all   |   ALT+Enter = send to mobile'
device_id="4384e464_c86f_47af_8585_8f170f36afea"

# Check if rofi is already running
if pidof rofi >/dev/null; then
    pkill rofi
fi

while true; do
    result=$(
        cliphist list -max-items 500 | sed 's/^[0-9]\+\s\+//' | rofi -i -dmenu \
            -kb-custom-1 "Control-Delete" \
            -kb-custom-2 "Alt-Delete" \
            -kb-custom-3 "Alt-Return"
    )

    exit_code=$?

    case "$exit_code" in
    1) # Cancel (Esc)
        exit
        ;;
    0) # Enter: copy back to clipboard
        if [ -z "$result" ]; then
            continue
        fi
        decoded_data=$(cliphist list -max-items 500 | grep -F -- "$result" | head -n 1 | cliphist decode)
        mime_type=$(echo "$decoded_data" | file --mime-type -b -)
        if [[ "$mime_type" == "image/png" ]]; then
            echo "$decoded_data" | xclip -selection clipboard -t image/png
        elif [[ "$mime_type" == "image/jpeg" ]]; then
            echo "$decoded_data" | xclip -selection clipboard -t image/jpeg
        else
            echo "$decoded_data" | xclip -selection clipboard
        fi
        exit
        ;;
    10) # Ctrl+Del: delete entry
        if [ -n "$result" ]; then
            cliphist list -max-items 500 | grep -F "$result" | head -n 1 | cliphist delete
        fi
        ;;
    11) # Alt+Del: wipe all
        cliphist wipe -max-items 500
        ;;
    12) # Alt+Enter: send to mobile
        if [ -z "$result" ]; then
            continue
        fi
        decoded_data=$(cliphist list -max-items 500 | grep -F -- "$result" | head -n 1 | cliphist decode)
        kdeconnect-cli --device "$device_id" --share-text "$decoded_data"
        notify-send -i /home/sh/.icons/WhiteSur/apps@2x/scalable/ktouch.svg \
            "Clipboard sent to phone" "     "
        exit
        ;;
    *) # any other code
        exit
        ;;
    esac
done
