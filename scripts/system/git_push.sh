#!/bin/bash

set -euo pipefail

# Global variables
GIT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || { printf "Not a git repository\n" >&2; exit 1; })
NVIM_COMMIT_MSG="Update nvim undo files"

# Function to check if there are any changes
check_git_status() {
    local status
    status=$(git status --porcelain)
    
    if [[ -z "$status" ]]; then
        printf "No changes to commit.\n"
        return 1
    fi
    return 0
}

# Function to stage files and commit with specific messages
stage_and_commit() {
    local file commit_msg
    local nvim_files=()

    while IFS= read -r file; do
        [[ -z "$file" ]] && continue
        
        if [[ "$file" == "nvim/undo/"* ]]; then
            nvim_files+=("$file")
        else
            commit_msg="Update $(basename "$file")"
            git add "$file"
            git commit -m "$commit_msg"
        fi
    done < <(git ls-files --modified --others --exclude-standard)

    if [[ ${#nvim_files[@]} -gt 0 ]]; then
        git add "${nvim_files[@]}"
        git commit -m "$NVIM_COMMIT_MSG"
    fi
}

# Function to push changes
push_changes() {
    local branch
    branch=$(git rev-parse --abbrev-ref HEAD)
    git push origin "$branch"
}

# Main execution
main() {
    if check_git_status; then
        stage_and_commit
        push_changes
    fi
}

main

