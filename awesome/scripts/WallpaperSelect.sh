#!/bin/bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */
# This script for selecting wallpapers (SUPER W) and updating AwesomeWM

# WALLPAPERS PATH
wallDIR="$HOME/Pictures/wallpapers"
SCRIPTSDIR="$HOME/.config/awesome/scripts"
WALLPAPER_FILE="$HOME/.config/awesome/wallpaper_path"

# Retrieve image files using null delimiter to handle spaces in filenames
mapfile -d '' PICS < <(find "${wallDIR}" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" \) -print0)

RANDOM_PIC="${PICS[$((RANDOM % ${#PICS[@]}))]}"
RANDOM_PIC_NAME=". random"

# Rofi command
rofi_command="rofi -i -show -dmenu -config ~/.config/rofi/config-wallpaper.rasi"

# Sorting Wallpapers
menu() {
    IFS=$'\n' sorted_options=($(sort <<<"${PICS[*]}"))
    printf "%s\x00icon\x1f%s\n" "$RANDOM_PIC_NAME" "$RANDOM_PIC"
    for pic_path in "${sorted_options[@]}"; do
        pic_name=$(basename "$pic_path")
        if [[ ! "$pic_name" =~ \.gif$ ]]; then
            printf "%s\x00icon\x1f%s\n" "$(echo "$pic_name" | cut -d. -f1)" "$pic_path"
        else
            printf "%s\n" "$pic_name"
        fi
    done
}

# Choice of wallpapers
main() {
    choice=$(menu | $rofi_command)
    choice=$(echo "$choice" | xargs)
    RANDOM_PIC_NAME=$(echo "$RANDOM_PIC_NAME" | xargs)

    if [[ -z "$choice" ]]; then
        echo "No choice selected. Exiting."
        exit 0
    fi

    if [[ "$choice" == "$RANDOM_PIC_NAME" ]]; then
        selected_wallpaper="$RANDOM_PIC"
    else
        pic_index=-1
        for i in "${!PICS[@]}"; do
            filename=$(basename "${PICS[$i]}")
            if [[ "$filename" == "$choice"* ]]; then
                pic_index=$i
                break
            fi
        done
        if [[ $pic_index -ne -1 ]]; then
            selected_wallpaper="${PICS[$pic_index]}"
        else
            echo "Image not found."
            exit 1
        fi
    fi

    # Write the selected wallpaper path to a file
    echo "$selected_wallpaper" >"$WALLPAPER_FILE"

    # Optionally still use feh as a fallback
    feh --bg-scale "$selected_wallpaper"

    # Run additional scripts
    sleep 2
    "$SCRIPTSDIR/WallustSwww.sh"
    sleep 0.5
    "$SCRIPTSDIR/Refresh.sh"
}

# Check if rofi is already running
if pidof rofi >/dev/null; then
    pkill rofi
fi
main
wait $!
"$SCRIPTSDIR/WallustSwww" &&
