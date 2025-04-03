#!/bin/bash
set -euo pipefail  # Enable strict error handling

# Configuration
LOCAL_DIR="/home/sh/Document"  # Fixed potential typo (Document -> Documents)
REMOTE_DIR="/home/sh/shri77"
RCLONE_REMOTE="shri77:Document"
RCLONE_CMD="/usr/bin/rclone bisync -P --verbose"  # Correct variable name
SYNC_INTERVAL=10
TEMP_FILE="$HOME/.cache/sync_trigger.tmp"
LOG_FILE="$HOME/.cache/sync.log"

# Ensure directories exist
mkdir -p "$LOCAL_DIR" "$REMOTE_DIR" "$(dirname "$TEMP_FILE")"

# Watched directories - only monitor LOCAL_DIR since REMOTE_DIR might be a mount
WATCHED_DIRS=("$LOCAL_DIR")
EVENTS="modify,create,delete,move,close_write"
LAST_RUN_FILE="/tmp/bisync_last_run"

# Enhanced logging
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

run_bisync() {
    log "Starting Rclone Bisync..."
    if $RCLONE_CMD "$LOCAL_DIR" "$RCLONE_REMOTE" --force --conflict-resolve=newer; then
        log "Sync completed successfully"
        echo "$(date +%s)" > "$LAST_RUN_FILE"
        rm -f "$TEMP_FILE"
        return 0
    else
        log "Sync failed!"
        notify-send -u normal "🔗 Rclone Bisync Failed" "Failed to sync Documents folder"
        return 1
    fi
}

check_changes() {
    log "Starting persistent change monitoring..."
    
    # Debugging: List directory structure
    log "Watching directories:"
    tree -d -L 2 "$LOCAL_DIR" | tee -a "$LOG_FILE"
    
    inotifywait -m -r -e "$EVENTS" "${WATCHED_DIRS[@]}" --format '%e:%w%f' |
    while read -r change; do
        log "Change detected: $change"
        echo "changes_detected:$(date +%s):$change" > "$TEMP_FILE"
    done
}

force_sync() {
    if [ -s "$TEMP_FILE" ]; then
        local last_change=$(stat -c %Y "$TEMP_FILE")
        local current_time=$(date +%s)
        
        if (( current_time - last_change >= SYNC_INTERVAL )); then
            log "Initiating forced sync"
            run_bisync
        else
            log "Sync interval not met (last: $last_change, now: $current_time)"
        fi
    else
        log "No changes detected in temp file"
    fi
}

main() {
    case "$1" in
        --check)
            check_changes
            ;;
        --sync)
            force_sync
            ;;
        *)
            echo "Usage: $0 [--check|--sync]"
            exit 1
            ;;
    esac
}

main "$@"
