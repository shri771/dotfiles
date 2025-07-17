#!/bin/bash

# Variables
rofi_theme="$HOME/.config/rofi/config-clipboard.rasi"
msg='👀 **note**  CTRL DEL = cliphist del (entry)   or   ALT DEL - cliphist wipe (all)'
# Actions:
# CTRL Del to delete an entry
# ALT Del to wipe clipboard contents

# Check if rofi is already running
if pidof rofi >/dev/null; then
    pkill rofi
fi

while true; do
    result=$(cliphist list -max-items 500 | sed 's/^[0-9]\+\s\+//' | rofi -i -dmenu \
        -kb-custom-1 "Control-Delete" \
        -kb-custom-2 "Alt-Delete")

    exit_code=$?

    case "$exit_code" in
    1) # Cancel
        exit
        ;;
    0) # OK
        if [ -z "$result" ]; then
            continue
        fi
        # Decode the selected entry from cliphist
        decoded_data=$(cliphist list -max-items 500 | grep -F -- "$result" | head -n 1 | cliphist decode)

        # Identify the MIME type of the decoded data
        # NOTE: Entries for images will appear as garbled text in Rofi.
        # This is a limitation of using text-based tools for binary data.
        mime_type=$(echo "$decoded_data" | file --mime-type -b -)

        # Copy data to the clipboard with the correct type
        if [[ "$mime_type" == "image/png" ]]; then
            echo "$decoded_data" | xclip -selection clipboard -t image/png
        elif [[ "$mime_type" == "image/jpeg" ]]; then
            echo "$decoded_data" | xclip -selection clipboard -t image/jpeg
        else
            # Assume text for everything else
            echo "$decoded_data" | xclip -selection clipboard
        fi
        exit
        ;;
    10) # Custom 1 (Delete)
        if [ -z "$result" ]; then
            continue
        fi
        cliphist list -max-items 500 | grep -F "$result" | head -n 1 | cliphist delete
        ;;
    11) # Custom 2 (Wipe)
        cliphist wipe -max-items 500
        ;;
    esac
done

