#!/bin/bash

sndel() {
    local snapshots_to_delete snap_id confirm
    
    # List snapshots
    if ! sudo snapper list; then
        printf "Error: Failed to list snapshots.\n" >&2
        return 1
    fi

    # Ask user for snapshot IDs to delete
    printf "Enter snapshot IDs to delete (space-separated): "
    read -r snapshots_to_delete

    # Validate input
    if [[ -z "$snapshots_to_delete" ]]; then
        printf "No snapshots provided. Exiting.\n" >&2
        return 1
    fi

    # Confirm deletion
    printf "You are about to delete snapshots: %s\n" "$snapshots_to_delete"
    read -r -p "Are you sure? (y/N) " confirm

    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        for snap_id in $snapshots_to_delete; do
            if ! [[ "$snap_id" =~ ^[0-9]+$ ]]; then
                printf "Skipping invalid snapshot ID: %s\n" "$snap_id" >&2
                continue
            fi
            if ! sudo snapper delete "$snap_id"; then
                printf "Error deleting snapshot: %s\n" "$snap_id" >&2
            fi
        done
        printf "Selected snapshots deleted successfully.\n"
    else
        printf "Deletion cancelled.\n"
    fi
}

sndel
