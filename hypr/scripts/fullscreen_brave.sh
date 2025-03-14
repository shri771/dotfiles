#!/bin/bash

set -euo pipefail

# Dependencies: hyprctl, ydotool, jq

is_any_brave_fullscreen() {
    local clients; clients=$(hyprctl clients -j 2>/dev/null) || return 1
    local monitors; monitors=$(hyprctl monitors -j 2>/dev/null) || return 1

    local screen_width; screen_width=$(jq -r '.[0].width // empty' <<< "$monitors")
    local screen_height; screen_height=$(jq -r '.[0].height // empty' <<< "$monitors")

    [[ -z "$screen_width" || -z "$screen_height" ]] && return 1

    # Loop through all windows
    while IFS= read -r win; do
        local win_class; win_class=$(jq -r '.class // empty' <<< "$win")
        local win_width; win_width=$(jq -r '.size[0] // empty' <<< "$win")
        local win_height; win_height=$(jq -r '.size[1] // empty' <<< "$win")

        # If any Brave window matches the monitor size, exit the script
        if [[ "$win_class" == "Brave-browser" && "$win_width" -eq "$screen_width" && "$win_height" -eq "$screen_height" ]]; then
            printf "A fullscreen Brave window was found. Exiting script.\n"
            exit 0  # Exits script immediately
        fi
    done <<< "$(jq -c '.[]' <<< "$clients")"

    return 1  # No fullscreen Brave found
}

process_brave_windows() {
    # If any Brave window is fullscreen, exit the script
    if is_any_brave_fullscreen; then
        exit 0
    fi

    local current_workspace; current_workspace=$(hyprctl activeworkspace -j | jq -r '.id') || return 1
    local brave_windows; brave_windows=$(hyprctl clients -j | jq -c --argjson ws "$current_workspace" '
        .[] | select(.class == "Brave-browser" and .workspace.id == $ws)') || return 1

    [[ -z "$brave_windows" ]] && { printf "No Brave windows detected in current workspace.\n"; return 0; }

    printf "\nProcessing Brave windows in current workspace...\n"

    # Loop through each window JSON object
    while IFS= read -r window; do
        local window_address; window_address=$(jq -r '.address' <<< "$window")

        printf "\nFocusing on window: %s\n" "$window_address"
        hyprctl dispatch focuswindow address:"$window_address" || { 
            printf "Failed to focus window: %s\n" "$window_address" >&2
            return 1
        }
        sleep 0.5

        printf "Sending Ctrl+P...\n"
        ydotool key 29:1 25:1 25:0 29:0
        sleep 0.2
        printf "Ctrl+P sent successfully.\n"

        printf "Sending Super+Space...\n"
        ydotool key 125:1 57:1 57:0 125:0
        sleep 0.2
        printf "Super+Space sent successfully.\n"
    done <<< "$brave_windows"

    printf "\nFinished processing all non-fullscreen Brave windows in current workspace.\n"
}

main() {
    if ! command -v hyprctl &>/dev/null || ! command -v ydotool &>/dev/null || ! command -v jq &>/dev/null; then
        printf "Error: Required dependencies (hyprctl, ydotool, jq) are missing.\n" >&2
        return 1
    fi

    process_brave_windows
}

main
