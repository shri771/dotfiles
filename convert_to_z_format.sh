#!/bin/bash

# Paths
FISH_HISTORY="$HOME/.local/share/fish/fish_history"
AUTOJUMP_DB="$HOME/.local/share/autojump/autojump.txt"
TMP_DB="/tmp/autojump.tmp"

# Create autojump DB if it doesn't exist
mkdir -p "$(dirname "$AUTOJUMP_DB")"
touch "$AUTOJUMP_DB"

# Parse Fish history for 'cd' commands and extract directories
grep 'cmd: cd' "$FISH_HISTORY" | awk -F 'cmd: cd ' '{print $2}' | \
while read -r dir; do
    # Clean directory path (remove quotes and resolve to absolute path)
    dir=$(echo "$dir" | sed "s/'//g; s/\"//g" | xargs)
    dir=$(realpath -m "$dir" 2>/dev/null)

    # Skip invalid/nonexistent directories
    [ -d "$dir" ] || continue

    # Update autojump database
    weight=10.0  # Default weight for each entry
    if grep -q "^$weight	$dir$" "$AUTOJUMP_DB"; then
        # Increment weight for existing entries
        awk -v dir="$dir" -v weight="$weight" \
            'BEGIN {FS=OFS="\t"} $2 == dir {$1 += weight; found=1} {print} END {if (!found) print weight, dir}' \
            "$AUTOJUMP_DB" > "$TMP_DB" && mv "$TMP_DB" "$AUTOJUMP_DB"
    else
        # Add new entry
        echo -e "${weight}\t${dir}" >> "$AUTOJUMP_DB"
    fi
done

# Remove duplicate entries (if any)
sort -u "$AUTOJUMP_DB" | sponge "$AUTOJUMP_DB"
