#!/usr/bin/env bash

# Git Worktree Switcher (Bare Repo Optimized)
# Shows only folder names and branch names

set -e

# Check if we are inside a git repository
if ! git rev-parse --git-dir &>/dev/null; then
    echo "Error: Not a git repository."
    exit 1
fi

check_dependencies() {
    for cmd in fzf nvim git eza; do
        if ! command -v "$cmd" &>/dev/null; then
            exit 1
        fi
    done
}

# 1. Parse worktrees into a clean list: "folder [branch] | full_path"
# 2. We ignore the .bare folder by filtering the worktree list
list_worktrees() {
    git worktree list --porcelain | awk '
        /^worktree/ {wp=$2}
        /^branch/ {
            split(wp, parts, "/");
            folder=parts[length(parts)];
            # Skip the .bare directory if it somehow shows up as a worktree
            if (folder != ".bare") {
                print folder " [" substr($2, 12) "] | " wp
            }
        }'
}

launch_fzf() {
    local selected
    selected=$(
        list_worktrees | fzf \
            --prompt="Switch Worktree > " \
            --height=60% \
            --layout=reverse \
            --border \
            --delimiter=' \| ' \
            --with-nth=1 \
            --preview="eza --tree --level=1 --color=always --icons \$(echo {2})" \
            --preview-window=right:50%:wrap \
            --header="ENTER: Open in Neovim | ESC: Cancel"
    )

    # Return only the full path (the part after the |)
    echo "$selected" | awk -F ' | ' '{print $2}'
}

main() {
    check_dependencies

    local target_dir
    target_dir=$(launch_fzf)

    if [ -z "$target_dir" ]; then
        exit 0
    fi

    if [ -d "$target_dir" ]; then
        cd "$target_dir"
        # Open Neovim and start Telescope
        nvim -c "lua require('telescope.builtin').find_files()"
    else
        exit 1
    fi
}

main
