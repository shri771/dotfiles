#!/bin/bash

# Step 1: Select a commit with preview
selected_commit=$(git log --oneline | fzf --height=50% --border \
    --preview "git show --color=always {1} --stat --patch" | awk '{print $1}')

# Exit if no commit was selected
if [[ -z "$selected_commit" ]]; then
    printf "❌ No commit selected. Exiting.\n"
    exit 0
fi

# Step 2: Select files with **real-time preview**
selected_files=$(git diff-tree --no-commit-id --name-only -r "$selected_commit" | 
    fzf --multi --height=40% --border --preview "git show --color=always $selected_commit -- {}" \
        --preview-window=up:60%:wrap)

# Step 3: Confirm before checkout
if [[ -z "$selected_files" ]]; then
    printf "⚠️ No files selected. The entire commit will be restored.\n"
    confirm_msg="Confirm full checkout to commit $selected_commit? (y/N): "
    checkout_cmd="git checkout $selected_commit"
else
    printf "✅ Selected files:\n"
    printf "%s\n" "$selected_files" | sed 's/^/- /'
    confirm_msg="Confirm restoring these files from commit $selected_commit? (y/N): "
    checkout_cmd="git checkout $selected_commit -- $selected_files"
fi

# Step 4: Ask for confirmation before executing checkout
printf "%s" "$confirm_msg"
read -r ans
if [[ "$ans" =~ ^[Yy]$ ]]; then
    eval "$checkout_cmd"
    printf "🎉 Successfully restored!\n"
else
    printf "❌ Operation canceled.\n"
fi
