#!/bin/bash

set -o pipefail

# Define script search locations
SCRIPT_LOCATIONS=("$HOME/scripts" "/usr/local/bin" )

# Function to find additional directories from Cascade Manager
find_cascade_dirs() {
    local cascade_dirs

    # Ensure Cascade Manager directories exist
    if [[ -d "/etc/cascade_manager" || -d "/var/lib/cascade_manager" ]]; then
        if ! cascade_dirs=$(find /etc/cascade_manager /var/lib/cascade_manager -type d 2>/dev/null); then
            printf "⚠️ No accessible Cascade Manager directories found.\n" >&2
            return 1
        fi
        printf "%s\n" "$cascade_dirs"
    fi
}

# Function to find executable scripts
find_scripts() {
    local scripts
    local all_locations=("${SCRIPT_LOCATIONS[@]}")

    # Add valid Cascade Manager directories
    if cascade_dirs=$(find_cascade_dirs); then
        while IFS= read -r dir; do
            [[ -d "$dir" ]] && all_locations+=("$dir")
        done <<< "$cascade_dirs"
    fi

    # Validate directories
    local valid_dirs=()
    for dir in "${all_locations[@]}"; do
        [[ -d "$dir" && -r "$dir" ]] && valid_dirs+=("$dir")
    done

    if [[ ${#valid_dirs[@]} -eq 0 ]]; then
        printf "❌ No valid script directories found.\n" >&2
        return 1
    fi

    # Find all executable scripts
    if ! scripts=$(find "${valid_dirs[@]}" -type f -executable 2>/dev/null); then
        printf "❌ Error finding scripts.\n" >&2
        return 1
    fi

    [[ -z "$scripts" ]] && printf "⚠️ No executable scripts found.\n" >&2 && return 1

    printf "%s\n" "$scripts"
}

# Main function
main() {
    local selected_script

    # Find scripts and use fzf for selection
    if ! selected_script=$(find_scripts | fzf --height=50% --border --preview "bat --style=numbers --color=always {}" --preview-window=up:50%"); then
        printf "❌ No script selected. Exiting.\n" >&2
        exit 0
    fi

    # Confirm execution
    printf "✅ Selected script: %s\nRun it? (y/N): " "$selected_script"
    read -r confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        printf "❌ Operation canceled.\n" >&2
        exit 0
    fi

    # Run script with sudo if necessary
    if [[ -w "$selected_script" && -x "$selected_script" ]]; then
        "$selected_script"
    else
        sudo "$selected_script"
    fi
}

main
