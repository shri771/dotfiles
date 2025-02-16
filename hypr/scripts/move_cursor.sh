#!/bin/bash

# Function to get the active window's position and size
get_window_geometry() {
    local geometry
    if ! geometry=$(hyprctl activewindow -j | jq -r '[.at[0], .at[1], .size[0], .size[1]] | @tsv'); then
        printf "Error: Failed to get active window geometry\n" >&2
        return 1
    fi

    # Ensure data is valid
    if [[ -z "$geometry" ]]; then
        printf "Error: Received empty window geometry\n" >&2
        return 1
    fi

    # Read values
    local x y w h
    read -r x y w h <<< "$geometry"

    # Validate numerical data
    if [[ ! "$x" =~ ^-?[0-9]+$ ]] || [[ ! "$y" =~ ^-?[0-9]+$ ]] || 
       [[ ! "$w" =~ ^[0-9]+$ ]] || [[ ! "$h" =~ ^[0-9]+$ ]]; then
        printf "Error: Invalid window geometry data\n" >&2
        return 1
    fi

    # Output values
    printf "%d %d %d %d\n" "$x" "$y" "$w" "$h"
}

# Function to move cursor to the center of the window
move_cursor_to_center() {
    local x y w h
    if ! read -r x y w h < <(get_window_geometry); then
        return 1
    fi

    # Calculate new cursor position with adjustments
    local new_x new_y
    new_x=$((x + w / 2))
    new_y=$((y + h / 2))

    if ! hyprctl dispatch movecursor "$new_x $new_y"; then
        printf "Error: Failed to move cursor\n" >&2
        return 1
    fi
}

# Run the function once
move_cursor_to_center
