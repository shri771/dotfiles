#!/usr/bin/env bash

# Bash Script Finder with FZF
# Silent mode - no output to terminal

SCRIPT_DIRS=(
    "/home/sh/scripts"
    "/home/sh/dotfiles/awesome/scripts"
    "/home/sh/dotfiles/hypr/scripts"
)

# Find all bash scripts
find_bash_scripts() {
    for dir in "${SCRIPT_DIRS[@]}"; do
        if [ -d "$dir" ]; then
            # Find .sh files
            find "$dir" -type f -name "*.sh" 2>/dev/null

            # Find files with bash shebang
            find "$dir" -type f ! -name "*.sh" -exec sh -c '
                for file; do
                    if head -n 1 "$file" 2>/dev/null | grep -qE "^#!/(usr/bin/env bash|bin/bash)"; then
                        echo "$file"
                    fi
                done
            ' sh {} +
        fi
    done | sort -u | sed "s|^$HOME/|~/|"
}

# Check if bat is available
if command -v bat &>/dev/null; then
    BAT_CMD="bat"
elif command -v batcat &>/dev/null; then
    BAT_CMD="batcat"
else
    BAT_CMD="cat"
fi

# Launch FZF and get selection
selected=$(find_bash_scripts | fzf \
    --prompt="Select Script > " \
    --height=60% \
    --layout=reverse \
    --border \
    --preview="$BAT_CMD --style=numbers --color=always --line-range :500 \$(echo {} | sed 's|^~/|$HOME/|') 2>/dev/null || cat \$(echo {} | sed 's|^~/|$HOME/|')" \
    --preview-window=right:40%:wrap \
    --header="ENTER: Execute | CTRL-E: Edit in Neovim | ESC: Cancel" \
    --bind "ctrl-e:execute(nvim \$(echo {} | sed 's|^~/|$HOME/|'))" \
    2>/dev/null)

# If nothing selected, exit
if [ -z "$selected" ]; then
    exit 0
fi

# Expand tilde
selected="${selected/#\~/$HOME}"

# Execute the script
if [ -f "$selected" ]; then
    if [ -x "$selected" ]; then
        "$selected"
    else
        bash "$selected"
    fi
fi
