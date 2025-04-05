#!/bin/bash

snrestore() {
    local snapshot_id confirm options

    # List available snapshots for the root config
    if ! sudo snapper --config root list; then
        printf "Error: Failed to list snapshots.\n" >&2
        return 1
    fi

    # Prompt user for snapshot ID to restore
    printf "Enter the snapshot ID to restore: "
    read -r snapshot_id

    # Validate input
    if [[ ! "$snapshot_id" =~ ^[0-9]+$ ]]; then
        printf "Invalid snapshot ID: %s\n" "$snapshot_id" >&2
        return 1
    fi

    # Confirm restoration
    printf "You are about to restore snapshot: %s\n" "$snapshot_id"
    read -r -p "Are you sure? (y/N) " confirm

    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        printf "Restoration cancelled.\n"
        return 0
    fi

    # Ask user for restoration options
    printf "\nSelect restore option:\n"
    printf "1) Restore files only\n"
    printf "2) Restore system state (rollback)\n"
    printf "3) Restore interactive mode\n"
    read -r -p "Choose an option (1/2/3): " options

    case "$options" in
        1)
            if ! sudo snapper --config root -v undochange 0.."$snapshot_id"; then
                printf "Error restoring files from snapshot: %s\n" "$snapshot_id" >&2
                return 1
            fi
            printf "Files restored from snapshot %s successfully.\n" "$snapshot_id"
            ;;
        2)
            if ! sudo snapper --config root --ambit classic -v rollback "$snapshot_id"; then
                printf "Error performing system rollback to snapshot: %s\n" "$snapshot_id" >&2
                return 1
            fi
            printf "System rollback to snapshot %s completed.\n" "$snapshot_id"
            printf "Reboot is recommended.\n"
            ;;
        3)
            if ! sudo snapper --config root -v status "$snapshot_id"; then
                printf "Error retrieving snapshot status: %s\n" "$snapshot_id" >&2
                return 1
            fi
            printf "Snapshot %s details displayed. Run 'snapper undochange' or 'snapper rollback' manually as needed.\n" "$snapshot_id"
            ;;
        *)
            printf "Invalid option selected.\n" >&2
            return 1
            ;;
    esac
}

snrestore
