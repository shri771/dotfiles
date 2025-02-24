#!/bin/bash

# Directories to monitor (space-separated)
WATCH_DIRS=("$HOME/scripts/" "$HOME/.config/hypr/scripts/" )  # Add more directories as needed

# Ensure directories exist
for dir in "${WATCH_DIRS[@]}"; do
    mkdir -p "$dir"
done

# Function to make new .sh files executable
make_executable() {
    local file="$1"
    if [[ -f "$file" && "$file" == *.sh ]]; then
        chmod +x "$file"
        printf "Made %s executable.\n" "$file"
    fi
}

# Find all subdirectories
get_all_dirs() {
    local all_dirs=()
    for dir in "${WATCH_DIRS[@]}"; do
        while IFS= read -r -d '' subdir; do
            all_dirs+=("$subdir")
        done < <(find "$dir" -type d -print0)
    done
    printf "%s\n" "${all_dirs[@]}"
}

# Start monitoring all directories and subdirectories
while IFS= read -r dir; do
    inotifywait -m -r -e create "$dir" --format '%w%f' &
done < <(get_all_dirs)

# Keep script running
wait
