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

# Function to stage files and create a single commit with a detailed message
stage_and_commit() {
    local file commit_msg commit_messages=()
    local nvim_files=()

    while IFS= read -r file; do
        [[ -z "$file" ]] && continue
        
        if [[ "$file" == "nvim/undo/"* ]]; then
            nvim_files+=("$file")
        else
            commit_messages+=("Update $(basename "$file")")
            git add "$file"
        fi
    done < <(git ls-files --modified --others --exclude-standard)

    if [[ ${#nvim_files[@]} -gt 0 ]]; then
        git add "${nvim_files[@]}"
        commit_messages+=("$NVIM_COMMIT_MSG")
    fi

    if [[ ${#commit_messages[@]} -gt 0 ]]; then
        commit_msg=$(printf "%s\n" "${commit_messages[@]}")
        git commit -m "$commit_msg"
    fi
}

# Function to push changes
push_changes() {
    local branch
    branch=$(git rev-parse --abbrev-ref HEAD)
    git push origin "$branch"
}

# Function to display git status with a separator
show_git_status() {
    printf "\n-----------------------\n"
    printf "Current Git Status:\n"
    printf "-----------------------\n"
    git status -s
}

# Main execution
main() {
    if check_git_status; then
        stage_and_commit
        push_changes
        show_git_status
    fi
}

main
