#!/bin/bash

SESSION_NAME="cn"

attach_or_create_tmux_session() {
    if tmux has-session -t "$SESSION_NAME" &>/dev/null; then
        tmux attach-session -t "$SESSION_NAME"
        return 0
    fi

    nvim +q

    if command -v tmuxifier &>/dev/null; then
        if tmuxifier load-session "$SESSION_NAME"; then
            return 0
        else
            printf "Failed to load Tmuxifier session '%s'\n" "$SESSION_NAME" >&2
            return 1
        fi
    else
        printf "Tmuxifier is not installed or not in your PATH\n" >&2
        return 1
    fi
}

attach_or_create_tmux_session

