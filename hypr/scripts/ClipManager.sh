#!/usr/bin/env bash

# Variables
rofi_theme="$HOME/.config/rofi/config-clipboard.rasi"
device_id="97a53fe1de984c6782388e683e17439f"
msg='👀 **note**  CTRL DEL = cliphist del (entry)   |   ALT DEL = cliphist wipe (all)   |   Shift+Enter = send to mobile'
# Actions:
# CTRL Del to delete an entry
# ALT Del to wipe clipboard contents
# ALT+Enter to send selected text to phone via KDE Connect

# Check if rofi is already running
if pidof rofi > /dev/null; then
  pkill rofi
fi

while true; do
    result=$(cliphist list | sed 's/^[0-9]\+\s\+//' | rofi -i -dmenu \
        -kb-custom-1 "Control-Delete" \
        -kb-custom-2 "Alt-Delete" \
        -kb-custom-3 "Alt-Return" )

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
        12) # Custom 3 (Send to phone)
            if [ -z "$result" ]; then
                continue
            fi
            decoded_data=$(cliphist list | grep -F -- "$result" | head -n 1 | cliphist decode)
            kdeconnect-cli --device "$device_id" --share-text "$decoded_data"
            notify-send "Clipboard sent to phone" "$result"
            exit
            ;;
    esac
done
