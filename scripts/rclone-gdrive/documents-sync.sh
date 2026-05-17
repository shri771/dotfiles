#!/bin/bash
set -euo pipefail

LOCAL_DIR="/home/shri/Documents"
RCLONE_REMOTE="shri77:Document"
LOG_FILE="$HOME/.cache/rclone-documents-sync.log"

mkdir -p "$LOCAL_DIR" "$(dirname "$LOG_FILE")"

log() {
  echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

run_bisync() {
  log "Starting rclone bisync for Documents"
  if rclone bisync "$LOCAL_DIR" "$RCLONE_REMOTE" -P --verbose --create-empty-src-dirs --conflict-resolve newer; then
    log "Sync completed successfully"
  else
    log "Sync failed"
    notify-send -u normal "Rclone bisync failed" "Failed to sync Documents folder"
    return 1
  fi
}

watch() {
  log "Watching $LOCAL_DIR for changes"
  inotifywait -m -r -e modify,create,delete,move,close_write "$LOCAL_DIR" --format '%e:%w%f' |
    while read -r change; do
      log "Change detected: $change"
      run_bisync
    done
}

case "${1:-}" in
  --watch)
    watch
    ;;
  --sync)
    run_bisync
    ;;
  --resync)
    exec rclone bisync "$LOCAL_DIR" "$RCLONE_REMOTE" --resync -P --verbose --create-empty-src-dirs --conflict-resolve newer
    ;;
  *)
    echo "Usage: $0 [--watch|--sync|--resync]"
    exit 1
    ;;
esac
