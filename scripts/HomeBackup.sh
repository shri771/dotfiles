#!/usr/bin/env bash

# HomeBackup.sh — Mount backup drive, prompt, and run borg backup in tmux
#
# Usage:
#   HomeBackup.sh          — Run as a normal user (mounts via sudo, prompts, backs up)
#   HomeBackup.sh --udev   — Run from a udev rule (mounts as root, re-execs into user session)

set -euo pipefail

# --- Configuration ---
BACKUP_USER="shri"
BACKUP_UID=$(id -u "$BACKUP_USER" 2>/dev/null || echo "1000")
ICON="/home/shri/Pictures/icons/preferences-system-backup.svg"
UUID="beda374d-ea22-4a53-a7e2-a685f598c3a1"
MOUNT_POINT="/mnt/home-backup"
SESSION_NAME="home-backup"
BORG_REPO="/mnt/home-backup/nix-backup"

# =============================================================================
# udev mode: mount as root, then hand off to user session
# =============================================================================
if [[ "${1:-}" == "--udev" ]]; then
    echo "HomeBackup: --udev triggered, running as $(whoami) (uid=$(id -u))" | systemd-cat -t home-backup -p info

    # Unmount stale mount if present, then mount fresh
    if mountpoint -q "$MOUNT_POINT"; then
        echo "HomeBackup: Unmounting stale $MOUNT_POINT..." | systemd-cat -t home-backup -p info
        umount -l "$MOUNT_POINT" 2>/dev/null || true
        sleep 1
    fi

    echo "HomeBackup: Mounting $MOUNT_POINT..." | systemd-cat -t home-backup -p info
    mount UUID="$UUID" "$MOUNT_POINT" || {
        echo "HomeBackup: Failed to mount $MOUNT_POINT" | systemd-cat -t home-backup -p err
        exit 1
    }
    echo "HomeBackup: Mount successful" | systemd-cat -t home-backup -p info

    # Re-exec as the user with their full session environment
    echo "HomeBackup: Re-execing as $BACKUP_USER..." | systemd-cat -t home-backup -p info
    exec runuser -u "$BACKUP_USER" -- env \
        PATH="/run/wrappers/bin:/run/current-system/sw/bin:/etc/profiles/per-user/$BACKUP_USER/bin:/home/$BACKUP_USER/.nix-profile/bin:$PATH" \
        DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$BACKUP_UID/bus" \
        WAYLAND_DISPLAY="wayland-1" \
        XDG_RUNTIME_DIR="/run/user/$BACKUP_UID" \
        GNUPGHOME="/home/$BACKUP_USER/.gnupg" \
        "$0"
fi

# =============================================================================
# User mode: everything runs as the logged-in user
# =============================================================================

# Ensure session env vars are set (safety net)
export DBUS_SESSION_BUS_ADDRESS="${DBUS_SESSION_BUS_ADDRESS:-unix:path=/run/user/$BACKUP_UID/bus}"
export WAYLAND_DISPLAY="${WAYLAND_DISPLAY:-wayland-1}"
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$BACKUP_UID}"
export GNUPGHOME="${GNUPGHOME:-/home/$BACKUP_USER/.gnupg}"

# --- Step 1: Mount the backup drive ---
if ! mountpoint -q "$MOUNT_POINT"; then
    if ! sudo mount UUID="$UUID" "$MOUNT_POINT"; then
        notify-send -u critical -i "$ICON" "Backup Error" "Failed to mount backup drive at $MOUNT_POINT"
        exit 1
    fi
fi

# --- Step 2: Ask user if they want to take backup ---
ACTION=$(notify-send -i "$ICON" \
    "Home Backup" \
    "Do you want to take backup?" \
    --action="yes=Yes" \
    --action="no=No")

if [[ "$ACTION" != "yes" ]]; then
    exit 0
fi

# --- Step 3: Get borg passphrase BEFORE tmux (GPG agent available here) ---
PASSPHRASE=$(pass borg/passphrase)
BORG_BIN=$(command -v borg)

# --- Step 4: Run borg backup in a detached tmux session ---
# Kill existing session if leftover from a previous run
tmux kill-session -t "$SESSION_NAME" 2>/dev/null || true

tmux new-session -d -s "$SESSION_NAME" \
    -e "BORG_PASSPHRASE=$PASSPHRASE" \
    -e "BORG_REPO=$BORG_REPO" \
    -e "BORG_BIN=$BORG_BIN" \
    -e "BACKUP_ICON=$ICON" \
    bash -c '
    echo "=== Home Backup Starting ==="
    echo "BORG_BIN=$BORG_BIN"
    echo "BORG_REPO=$BORG_REPO"
    echo "PATH=$PATH"
    echo ""

    if sudo BORG_PASSPHRASE="$BORG_PASSPHRASE" \
            BORG_REPO="$BORG_REPO" \
            "$BORG_BIN" create \
        --verbose \
        --stats \
        --progress \
        --compression lz4 \
        --patterns-from /root/.config/borg/backup-patterns.lst \
        --exclude-caches \
        --exclude-if-present .nobackup \
        --one-file-system \
        "$BORG_REPO"::"{hostname}-{user}-{now:%Y-%m-%dT%H:%M}" \
        /home/shri; then
        notify-send -i "$BACKUP_ICON" "Backup Complete ✅" "Home backup completed successfully!"
    else
        echo ""
        echo "=== BACKUP FAILED (exit code: $?) ==="
        echo "Session kept alive for debugging. Run: tmux attach -t home-backup"
        notify-send -u critical -i "$BACKUP_ICON" "Backup Failed ❌" "Home backup encountered an error."
    fi

    # Keep session alive for inspection
    exec bash
'

notify-send -i "$ICON" "Backup Started" "Borg backup is running in the background (tmux: $SESSION_NAME)"
