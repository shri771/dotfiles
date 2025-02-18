#!/bin/bash
# Clipboard Manager using cliphist, rofi, and wl-copy for Hyprland.

set -euo pipefail

# Ensure dependencies are installed
check_dependencies() {
    local deps=("rofi" "cliphist" "wl-copy" "wtype" "hyprctl")
    for cmd in "${deps[@]}"; do
        if ! command -v "$cmd" &>/dev/null; then
            printf "Error: Required command '%s' not found. Please install it.\n" "$cmd" >&2
            return 1
        fi
    done
}

# Get cursor position from Hyprland
get_cursor_position() {
    local cursorpos x y
    cursorpos=$(hyprctl cursorpos 2>/dev/null) || return 1

    if ! [[ "$cursorpos" =~ ^([0-9]+),\ ([0-9]+)$ ]]; then
        printf "Error: Invalid cursor position retrieved: '%s'\n" "$cursorpos" >&2
        return 1
    fi

    x="${BASH_REMATCH[1]}"
    y="${BASH_REMATCH[2]}"

    printf "%s %s\n" "$x" "$y"
}

# Calculate Rofi window position with proper edge gaps
calculate_rofi_position() {
    local x=$1
    local y=$2
    local screen_width=1920  # Replace with your screen width
    local screen_height=1200 # Replace with your screen height
    local rofi_width=$((screen_width * 30 / 100))  # 30% of screen width
    local rofi_height=$((screen_height * 40 / 100)) # 40% of screen height
    local edge_gap=20  # Minimum gap from edges
    local bottom_gap=45 # Additional gap when near the bottom

    # Adjust X position if near the right or left edge
    if ((x + rofi_width > screen_width - edge_gap)); then
        x=$((screen_width - rofi_width - edge_gap))
    elif ((x < edge_gap)); then
        x=$edge_gap
    fi

    # Adjust Y position if near the bottom or top edge
    if ((y + rofi_height > screen_height - edge_gap)); then
        y=$((screen_height - rofi_height - bottom_gap))
    elif ((y > screen_height - rofi_height)); then
        y=$((screen_height - rofi_height - bottom_gap))
    elif ((y < edge_gap)); then
        y=$edge_gap
    fi

    printf "%s %s\n" "$x" "$y"
}

# Display Rofi with clipboard history
clipboard_manager() {
    local x y selection
    read -r x y < <(get_cursor_position) || return 1
    read -r x y < <(calculate_rofi_position "$x" "$y")

    local history
    history=$(cliphist list) || return 1
    [[ -z "$history" ]] && history="No clipboard history available"

    printf "Launching Rofi at X:%s Y:%s\n" "$x" "$y" >&2

    selection=$(echo "$history" | rofi -i -dmenu \
        -config ~/.config/rofi/config-clipboard.rasi \
        -theme-str "window { location: northwest; x-offset: ${x}px; y-offset: ${y}px; }" \
        -kb-move-up "Control+p" \
        -kb-move-down "Control+n" \
        -kb-accept-entry "Return"
    ) || return 1

    [[ "$selection" == "No clipboard history available" ]] && return

    cliphist decode <<<"$selection" | wl-copy

    # Paste the selected item automatically
    wtype -M ctrl v -m ctrl
}

main() {
    check_dependencies || exit 1
    clipboard_manager
}

main
