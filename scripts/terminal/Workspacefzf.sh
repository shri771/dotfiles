#!/usr/bin/env bash

# Workspace Directory Launcher with FZF and Neovim + Telescope
# Silent mode - no output to terminal

set -e

WORKSPACE_DIR="$HOME/WorkSpace"

# Check if required commands exist (silent)
check_dependencies() {
    local missing_deps=()

    for cmd in fzf nvim eza find; do
        if ! command -v "$cmd" &>/dev/null; then
            missing_deps+=("$cmd")
        fi
    done

    if [ ${#missing_deps[@]} -ne 0 ]; then
        exit 1
    fi
}

# Check and handle WorkSpace directory (silent)
check_workspace() {
    if [ ! -d "$WORKSPACE_DIR" ]; then
        read -p "Enter alternative directory path: " alt_dir 2>/dev/null

        # Expand tilde if present
        alt_dir="${alt_dir/#\~/$HOME}"

        if [ -z "$alt_dir" ] || [ ! -d "$alt_dir" ]; then
            exit 1
        fi

        WORKSPACE_DIR="$alt_dir"
    fi
}

# Find all directories (excluding hidden ones)
find_directories() {
    find "$WORKSPACE_DIR" -type d -not -path '*/\.*' 2>/dev/null | sed "s|^$WORKSPACE_DIR/||" | sed "s|^$WORKSPACE_DIR$|.|"
}

# Launch FZF with preview
launch_fzf() {
    local selected_dir

    selected_dir=$(
        find_directories | fzf \
            --prompt="Select Directory > " \
            --height=60% \
            --layout=reverse \
            --border \
            --preview="eza -D --color=always '$WORKSPACE_DIR/{}' 2>/dev/null || echo 'Empty directory'" \
            --preview-window=right:40%:wrap \
            --header="Press ENTER to open in Neovim | ESC to cancel" \
            2>/dev/null
    )

    echo "$selected_dir"
}

# Main function
main() {
    # Check dependencies
    check_dependencies 2>/dev/null

    # Check workspace directory
    check_workspace 2>/dev/null

    # Launch FZF
    local selected_dir
    selected_dir=$(launch_fzf)

    if [ -z "$selected_dir" ]; then
        exit 0
    fi

    # Handle "." for root workspace directory
    if [ "$selected_dir" = "." ]; then
        selected_dir="$WORKSPACE_DIR"
    else
        selected_dir="$WORKSPACE_DIR/$selected_dir"
    fi

    # Change to directory and launch neovim with telescope
    if [ -d "$selected_dir" ]; then
        cd "$selected_dir" 2>/dev/null || exit 1
        nvim -c "lua require('telescope.builtin').find_files()" 2>/dev/null
    else
        exit 1
    fi
}

# Run main function (completely silent)
main 2>/dev/null
