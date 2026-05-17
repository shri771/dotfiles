#!/bin/bash
set -euo pipefail

MOUNT_DIR="/home/shri/Drive/Shri77"

mkdir -p "$MOUNT_DIR"
exec rclone mount shri77:Document "$MOUNT_DIR" \
  --vfs-cache-mode writes \
  --dir-cache-time 1h \
  --poll-interval 2m \
  --no-modtime \
  --umask 022
