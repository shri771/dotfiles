#!/bin/bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */
# Universal Wallust for Hyprland or AwesomeWM

# where Rofi expects the link
ROFI_WALL="$HOME/.config/rofi/.current_wallpape"

# AWESOME effects dir
EFFECTS_DIR="$HOME/.config/awesome/wallpaper_effects"

# make sure Roo-fi and effects folders exist
mkdir -p "$(dirname "$ROFI_WALL")"

# if EFFECTS_DIR exists but isn’t a directory, back it up
if [ -e "$EFFECTS_DIR" ] && [ ! -d "$EFFECTS_DIR" ]; then
    mv "$EFFECTS_DIR" "${EFFECTS_DIR}.bak.$(date +%s)"
fi
mkdir -p "$EFFECTS_DIR"

run_wallust() {
    local wp="$1"
    ln -sf "$wp" "$ROFI_WALL" &&
        cp "$wp" "$EFFECTS_DIR/.wallpaper_current" &&
        echo "🚀 wallust on $wp" &&
        wallust run "$wp" -s &
}

# 1) Hyprland via swww + hyprctl
if command -v hyprctl &>/dev/null && [ -d "$HOME/.cache/swww" ]; then
    cache_dir="$HOME/.cache/swww/"
    current_monitor=$(hyprctl monitors |
        awk '/^Monitor/{n=$2} /focused: yes/{print n}')
    cache_file="${cache_dir}${current_monitor}"
    if [ -f "$cache_file" ]; then
        wp=$(grep -v 'Lanczos3' "$cache_file" | head -n1)
        [ -f "$wp" ] && run_wallust "$wp"
        exit
    fi
fi

# 2) AwesomeWM via ~/.fehbg
if [ -f "$HOME/.fehbg" ]; then
    wp=$(sed -n "s/.*'\(.*\)'.*/\1/p" "$HOME/.fehbg")
    if [ -f "$wp" ]; then
        run_wallust "$wp"
        exit
    else
        echo "⚠️ Can't find $wp from ~/.fehbg"
        exit 1
    fi
fi

echo "⚠️ No Hyprland or feh setup found."
exit 1
