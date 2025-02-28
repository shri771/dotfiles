#!/bin/bash

set -o pipefail  # Ensure pipeline failures are caught

# Ensure we are inside a Git repository
if ! git rev-parse --is-inside-work-tree &>/dev/null; then
    printf "❌ Not inside a Git repository. Exiting.\n" >&2
    exit 1
fi

# Step 1: Select a commit with preview (Latest commits first)
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

# Step 3: Sanitize and validate selected files
if [[ -z "$selected_files" ]]; then
    printf "⚠️ No files selected. The entire commit will be restored.\n"
    confirm_msg="Confirm full checkout to commit $selected_commit? (y/N): "
    checkout_cmd=("git" "checkout" "$selected_commit")
else
    printf "✅ Selected files:\n"
    printf "%s\n" "$selected_files" | sed 's/^/- /'

    # Convert multi-line output to array & trim spaces
    mapfile -t files_array < <(echo "$selected_files" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

    # Verify that selected files exist in the repository history
    valid_files=()
    for file in "${files_array[@]}"; do
        if git ls-tree --full-tree -r "$selected_commit" -- "$file" &>/dev/null; then
            valid_files+=("$file")
        else
            printf "⚠️ Warning: File '%s' does not exist in commit history. Skipping.\n" "$file" >&2
        fi
    done

    # If no valid files remain, abort operation
    if [[ ${#valid_files[@]} -eq 0 ]]; then
        printf "❌ No valid files selected. Aborting.\n" >&2
        exit 1
    fi

    confirm_msg="Confirm restoring these files from commit $selected_commit? (y/N): "
    checkout_cmd=("git" "checkout" "$selected_commit" "--" "${valid_files[@]}")
fi

# Step 4: Ask for confirmation before executing checkout
printf "%s" "$confirm_msg"
read -r ans
if [[ "$ans" =~ ^[Yy]$ ]]; then
    if "${checkout_cmd[@]}"; then
        printf "🎉 Successfully restored!\n"
    else
        printf "❌ Error restoring files. Please check if the paths exist in Git.\n" >&2
    fi
else
    printf "❌ Operation canceled.\n"
fi
