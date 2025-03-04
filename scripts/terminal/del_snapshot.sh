#!/bin/bash

sndel() {
    local snapshots_to_delete snap_id confirm expanded_list start end

    # List snapshots
    if ! sudo snapper list; then
        printf "Error: Failed to list snapshots.\n" >&2
        return 1
    fi

    # Ask user for snapshot IDs or range to delete
    printf "Enter snapshot IDs to delete (space-separated or range like 1-90): "
    read -r snapshots_to_delete

    # Validate input
    if [[ -z "$snapshots_to_delete" ]]; then
        printf "No snapshots provided. Exiting.\n" >&2
        return 1
    fi

    # Expand ranges into individual snapshot IDs
    expanded_list=""
    for snap_id in $snapshots_to_delete; do
        if [[ "$snap_id" =~ ^[0-9]+$ ]]; then
            expanded_list+=" $snap_id"
        elif [[ "$snap_id" =~ ^([0-9]+)-([0-9]+)$ ]]; then
            start="${BASH_REMATCH[1]}"
            end="${BASH_REMATCH[2]}"
            if (( start > end )); then
                printf "Invalid range: %s. Skipping.\n" "$snap_id" >&2
                continue
            fi
            for ((i = start; i <= end; i++)); do
                expanded_list+=" $i"
            done
        else
            printf "Skipping invalid input: %s\n" "$snap_id" >&2
        fi
    done

    # Remove duplicate IDs and sort them
    expanded_list=$(echo "$expanded_list" | tr ' ' '\n' | sort -nu)

    # Confirm deletion
    printf "You are about to delete snapshots: %s\n" "$expanded_list"
    read -r -p "Are you sure? (y/N) " confirm

    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        for snap_id in $expanded_list; do
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
