function gw --description "Switch Git Worktree"
    # 1. Check if we are in a git repo
    if not git rev-parse --is-inside-work-tree >/dev/null 2>&1; and not git rev-parse --is-bare-repository >/dev/null 2>&1
        echo "Error: Not a git repository"
        return 1
    end

    # 2. Check dependencies
    for cmd in fzf git eza
        if not command -q $cmd
            echo "Error: $cmd is not installed"
            return 1
        end
    end

    # 3. Get the list of worktrees
    # Format: branch-name<TAB>/full/path/to/worktree
    set worktree_list (git worktree list --porcelain | awk '
        /^worktree/ {wp=$2}
        /^branch/ {
            split(wp, parts, "/");
            folder=parts[length(parts)];
            # Skip the .bare directory
            if (folder != ".bare") {
                # Show only the branch name (strip refs/heads/)
                print substr($2, 12) "\t" wp
            }
        }')

    # 4. Show nothing if no worktrees found
    if test -z "$worktree_list"
        echo "No worktrees found"
        return 1
    end

    # 5. Fuzzy search with tree preview
    set selected (printf "%s\n" $worktree_list | fzf \
        --ansi \
        --delimiter='\t' \
        --with-nth=1 \
        --prompt="Switch Worktree > " \
        --height=60% \
        --layout=reverse \
        --border \
        --header="ENTER: Switch | ESC: Cancel" \
        --preview="eza --tree --level=1 --color=always --icons {2}" \
        --preview-window=right:50%:wrap)

    # 6. If a selection was made, extract path and switch
    if test -n "$selected"
        set target_dir (echo "$selected" | awk -F '\t' '{print $2}')

        if test -d "$target_dir"
            cd "$target_dir"
        else
            echo "Error: Directory not found: $target_dir"
            return 1
        end
    end
end
