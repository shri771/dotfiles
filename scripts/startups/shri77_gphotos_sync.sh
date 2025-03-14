#!/bin/bash

LOCAL_DIR="/home/sh/Pictures/Screenshots/"
REMOTE_DIR="shri77:album/Screenshots"
RCLONE_CMD="/usr/bin/rclone bisync -P"
SYNC_INTERVAL=10
DEBOUNCE_DELAY=3  # Ignore repeated MODIFY events for 3 seconds

WATCHED_DIRS=("$LOCAL_DIR")
EVENTS="modify,create,delete,move"
LAST_RUN_FILE="/tmp/bisync_last_run"
LAST_FILE_CHANGED="/tmp/bisync_last_file"
LOG_FILE="/tmp/bisync_debug.log"
DEBUG=true  # Set to false to disable debug logs

log_message() {
    local message="$1"
    printf "[%s] %s\n" "$(date '+%Y-%m-%d %H:%M:%S')" "$message" | tee -a "$LOG_FILE"
}

debug_message() {
    if [[ "$DEBUG" == true ]]; then
        log_message "DEBUG: $1"
    fi
}

validate_directories() {
    local dir
    for dir in "${WATCHED_DIRS[@]}"; do
        if [[ ! -d "$dir" ]]; then
            log_message "ERROR: Directory '$dir' does not exist."
            return 1
        fi
    done
}

run_bisync() {
    local current_time; current_time=$(date +%s)
    local last_run; last_run=$(cat "$LAST_RUN_FILE" 2>/dev/null || echo 0)

    if (( current_time - last_run >= SYNC_INTERVAL )); then
        log_message "Change detected! Running Rclone Bisync..."
        
        if $RCLONE_CMD "$LOCAL_DIR" "$REMOTE_DIR" --force --conflict-resolve=newer --verbose 2>&1 | tee -a "$LOG_FILE"; then
            echo "$current_time" > "$LAST_RUN_FILE"
            log_message "Rclone Bisync completed successfully."
        else
            log_message "ERROR: Rclone Bisync failed."
        fi
    else
        log_message "Change detected, but skipping sync (too soon)."
    fi
}

monitor_changes() {
    debug_message "Starting inotifywait on directories: ${WATCHED_DIRS[*]}"

    inotifywait -m -r -e "$EVENTS" --format '%w%f %e' "${WATCHED_DIRS[@]}" --quiet |
    while read -r changed_file event; do
        local current_time; current_time=$(date +%s)
        local last_event_time; last_event_time=$(cat "$LAST_FILE_CHANGED" 2>/dev/null | awk '{print $2}' || echo 0)
        local last_file; last_file=$(cat "$LAST_FILE_CHANGED" 2>/dev/null | awk '{print $1}' || echo "")

        debug_message "Event detected: File '$changed_file' with action '$event'"

        # If it's the same file and happened within debounce delay, ignore it
        if [[ "$event" == "MODIFY" && "$changed_file" == "$last_file" ]] && (( current_time - last_event_time < DEBOUNCE_DELAY )); then
            debug_message "Ignoring duplicate modify event for '$changed_file' (debounced)."
            continue
        fi

        echo "$changed_file $current_time" > "$LAST_FILE_CHANGED"

        if [[ -e "$changed_file" || "$event" == "DELETE" || "$event" == "MOVED_FROM" ]]; then
            log_message "File change detected: $changed_file ($event)"
            run_bisync
        else
            log_message "WARNING: Detected change but file does not exist: $changed_file"
        fi
    done
}

manual_trigger() {
    log_message "Manual trigger: Running Bisync now..."
    run_bisync
}

main() {
    log_message "Starting directory monitor for changes..."

    if ! validate_directories; then
        log_message "ERROR: One or more directories are invalid. Exiting."
        return 1
    fi

    if [[ "$1" == "--manual" ]]; then
        manual_trigger
        return 0
    fi

    monitor_changes
}

main "$@"
