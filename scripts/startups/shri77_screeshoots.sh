#!/bin/bash

LOCAL_DIR="/home/sh/Pictures/Screenshots/"
REMOTE_DIR="/home/sh/shri77/Screenshots/"
RCLONE_REMOTE="shri77:Screenshots"
RCLONE_CMD="/usr/bin/rclone bisync -P"
SYNC_INTERVAL=10

WATCHED_DIRS=("$LOCAL_DIR" "$REMOTE_DIR")
EVENTS="modify,create,delete,move"
LAST_RUN_FILE="/tmp/bisync_last_run"

run_bisync() {
    local current_time; current_time=$(date +%s)
    local last_run; last_run=$(cat "$LAST_RUN_FILE" 2>/dev/null || echo 0)

    if (( current_time - last_run >= SYNC_INTERVAL )); then
        printf "[%s] Change detected! Running Rclone Bisync...\n" "$(date)"
        if $RCLONE_CMD "$LOCAL_DIR" "$RCLONE_REMOTE" --force --conflict-resolve=newer; then
            echo "$current_time" > "$LAST_RUN_FILE"
        else
            printf "[%s] Rclone Bisync failed.\n" "$(date)" >&2
            notify-send -u critical "Rclone Bisync Failed" "Failed to sync Screenshots folder"
        fi
    else
        printf "[%s] Change detected, but skipping sync (too soon).\n" "$(date)"
    fi
}

monitor_changes() {
    inotifywait -m -r -e "$EVENTS" "${WATCHED_DIRS[@]}" --format '%w%f' --quiet |
    while read -r changed_file; do
        if [[ -n "$changed_file" ]]; then
            run_bisync
        fi
    done
}

main() {
    printf "[%s] Starting directory monitor for changes...\n" "$(date)"
    monitor_changes
}

main
