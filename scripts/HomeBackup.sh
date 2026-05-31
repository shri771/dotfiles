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
NOTIFY_TIMEOUT=3000
ACTION_NOTIFY_TIMEOUT=0
UUID="beda374d-ea22-4a53-a7e2-a685f598c3a1"
MOUNT_POINT="/mnt/home-backup"
SESSION_NAME="home-backup"
BORG_REPO="/mnt/home-backup/nix-backup"
BACKUP_STATUS_FILE="/tmp/${SESSION_NAME}-status-$$"

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

    # Run the interactive backup flow as the user with their full session environment.
    # Keep this root process alive so it can unmount after the user confirms.
    echo "HomeBackup: Running backup flow as $BACKUP_USER..." | systemd-cat -t home-backup -p info
    set +e
    runuser -u "$BACKUP_USER" -- env \
        PATH="/run/wrappers/bin:/run/current-system/sw/bin:/etc/profiles/per-user/$BACKUP_USER/bin:/home/$BACKUP_USER/.nix-profile/bin:$PATH" \
        DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$BACKUP_UID/bus" \
        WAYLAND_DISPLAY="wayland-1" \
        XDG_RUNTIME_DIR="/run/user/$BACKUP_UID" \
        GNUPGHOME="/home/$BACKUP_USER/.gnupg" \
        HOME_BACKUP_UDEV=1 \
        "$0"
    user_exit=$?
    set -e

    if [[ "$user_exit" -eq 10 ]]; then
        echo "HomeBackup: User requested unmount; syncing..." | systemd-cat -t home-backup -p info
        sync
        if umount_error=$(umount "$MOUNT_POINT" 2>&1); then
            echo "HomeBackup: Unmounted $MOUNT_POINT" | systemd-cat -t home-backup -p info
            exit 0
        fi

        echo "HomeBackup: Failed to unmount $MOUNT_POINT: $umount_error" | systemd-cat -t home-backup -p err
        runuser -u "$BACKUP_USER" -- env \
            PATH="/run/wrappers/bin:/run/current-system/sw/bin:/etc/profiles/per-user/$BACKUP_USER/bin:/home/$BACKUP_USER/.nix-profile/bin:$PATH" \
            DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$BACKUP_UID/bus" \
            WAYLAND_DISPLAY="wayland-1" \
            XDG_RUNTIME_DIR="/run/user/$BACKUP_UID" \
            notify-send -t "$NOTIFY_TIMEOUT" -u critical -i "$ICON" "Unmount Failed" "$umount_error" || true
        exit 1
    fi

    exit "$user_exit"
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
        notify-send -t "$NOTIFY_TIMEOUT" -u critical -i "$ICON" "Backup Error" "Failed to mount backup drive at $MOUNT_POINT"
        exit 1
    fi
fi

# --- Step 2: Ask user if they want to take backup ---
ACTION=$(notify-send -t "$ACTION_NOTIFY_TIMEOUT" -i "$ICON" \
    "Home Backup" \
    "Do you want to take backup?" \
    --action="yes=Yes" \
    --action="no=No" || true)
echo "HomeBackup: Backup prompt action='$ACTION'" | systemd-cat -t home-backup -p info

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
    -e "NOTIFY_TIMEOUT=$NOTIFY_TIMEOUT" \
    -e "BACKUP_STATUS_FILE=$BACKUP_STATUS_FILE" \
    bash -c '
    echo "=== Home Backup Starting ==="
    echo "BORG_BIN=$BORG_BIN"
    echo "BORG_REPO=$BORG_REPO"
    echo "PATH=$PATH"
    echo ""

    sudo BORG_PASSPHRASE="$BORG_PASSPHRASE" \
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
        /home/shri
    borg_exit=$?

    if [[ "$borg_exit" -eq 1 ]]; then
        echo ""
        echo "=== BACKUP COMPLETED WITH WARNINGS (exit code: $borg_exit) ==="
        echo "Some files were skipped. Check the Borg output above for details."
    elif [[ "$borg_exit" -ne 0 ]]; then
        echo ""
        echo "=== BACKUP FAILED (exit code: $borg_exit) ==="
        echo "Session kept alive for debugging. Run: tmux attach -t home-backup"
        notify-send -t "$NOTIFY_TIMEOUT" -u critical -i "$BACKUP_ICON" "Backup Failed ❌" "Home backup encountered an error."
    fi

    printf "%s\n" "$borg_exit" > "$BACKUP_STATUS_FILE"

    # Keep session alive for inspection
    exec bash
'

notify-send -t "$NOTIFY_TIMEOUT" -i "$ICON" "Backup Started" "Borg backup is running in the background (tmux: $SESSION_NAME)"

while [[ ! -s "$BACKUP_STATUS_FILE" ]]; do
    if ! tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
        notify-send -t "$NOTIFY_TIMEOUT" -u critical -i "$ICON" "Backup Error" "Backup tmux session ended without reporting status."
        exit 1
    fi
    sleep 1
done

borg_exit=$(cat "$BACKUP_STATUS_FILE")
rm -f "$BACKUP_STATUS_FILE"

if [[ "$borg_exit" -eq 0 || "$borg_exit" -eq 1 ]]; then
    if [[ "$borg_exit" -eq 1 ]]; then
        backup_message="Backup completed with warnings. Unmount $MOUNT_POINT now?"
    else
        backup_message="Backup completed successfully. Unmount $MOUNT_POINT now?"
    fi

    UNMOUNT_ACTION=$(notify-send -t "$ACTION_NOTIFY_TIMEOUT" -i "$ICON" \
        "Backup Complete" \
        "$backup_message" \
        --action="yes=Yes" \
        --action="no=No" || true)
    echo "HomeBackup: Unmount prompt action='$UNMOUNT_ACTION'" | systemd-cat -t home-backup -p info

    if [[ "$UNMOUNT_ACTION" == "yes" ]]; then
        if [[ "${HOME_BACKUP_UDEV:-0}" == "1" ]]; then
            exit 10
        fi

        sync
        if umount_error=$(sudo umount "$MOUNT_POINT" 2>&1); then
            :
        else
            notify-send -t "$NOTIFY_TIMEOUT" -u critical -i "$ICON" "Unmount Failed" "$umount_error"
        fi
    fi
fi
