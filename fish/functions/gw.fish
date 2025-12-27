function gw --description "Switch Git Worktree"
    # Check if we're in a git repo
    if not git rev-parse --git-dir >/dev/null 2>&1
        echo "Error: Not a git repository"
        return 1
    end

    # Get current worktree root and relative path within it
    set -l current_worktree (git rev-parse --show-toplevel 2>/dev/null)
    set -l current_dir (pwd)
    set -l relative_path (string replace "$current_worktree" "" "$current_dir")

    # Pipe directly: git → awk → fzf
    set -l selected (git worktree list --porcelain | awk '
        /^worktree/ { wp = $2 }
        /^branch/ { if (wp !~ /\.bare$/) print substr($2, 12) "\t" wp }
    ' | fzf \
        --delimiter='\t' \
        --with-nth=1 \
        --prompt="Worktree > " \
        --height=40% \
        --layout=reverse \
        --border \
        --preview="ls -la --color=always {2} 2>/dev/null | head -20" \
        --preview-window=right:40%)

    # Switch if selected
    if test -n "$selected"
        set -l target_worktree (echo $selected | cut -f2)
        set -l target_dir "$target_worktree$relative_path"

        # Try to cd to same relative path, fallback to worktree root
        if test -d "$target_dir"
            cd "$target_dir"
        else
            cd "$target_worktree"
        end
    end
end
