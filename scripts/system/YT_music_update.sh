#!/bin/bash

# Global Variables
BASE_DIR="$HOME/Downloads/Music"
declare -A PLAYLISTS
PLAYLISTS=(
    ["Cheerful"]="https://music.youtube.com/playlist?list=PLOlHDApPp3YvM3Ov9rnFCrT5jha8DWVGu&si=hKimloi5pBslW9Q8"
    ["Feel-Good💖"]="https://music.youtube.com/playlist?list=PLOlHDApPp3YtOYIj_1S_NSBLavu9JsoNY&si=NC7GATEan10SfjU6"
    ["Remix"]="https://music.youtube.com/playlist?list=PLOlHDApPp3Yu68BquCuanfY5VOF4dFBk7&si=nYNAssUDjcSU2nUY"
)

# Function to sanitize filenames
sanitize_filename() {
    local filename="$1"
    filename=$(printf '%s' "$filename" | sed 's/[\/:*?"<>|]/_/g')
    printf '%s' "$filename"
}

# Function to get playlist song titles and URLs
get_playlist_songs() {
    local playlist_url="$1"
    local output
    if ! output=$(yt-dlp --flat-playlist --print "%(title)s|%(webpage_url)s" "$playlist_url" 2>/dev/null); then
        printf "Error retrieving playlist: %s\n" "$playlist_url" >&2
        return 1
    fi
    printf '%s\n' "$output"
}

# Function to check if a song exists locally
song_exists_locally() {
    local song_title="$1"
    local download_dir="$2"
    local sanitized_title; sanitized_title=$(sanitize_filename "$song_title")
    local song_path="$download_dir/$sanitized_title.mp3"
    [[ -f "$song_path" ]]
}

# Function to download a song
download_song() {
    local song_url="$1"
    local sanitized_title="$2"
    local download_dir="$3"
    local output_path="$download_dir/$sanitized_title.%(ext)s"

    printf "Downloading: %s\n" "$sanitized_title"
    if ! yt-dlp -f bestaudio --extract-audio --audio-format mp3 --audio-quality 0 \
        --embed-thumbnail --embed-metadata --parse-metadata "thumbnail:%(meta_thumbnail)s" \
        -o "$output_path" "$song_url"; then
        printf "Download failed for: %s\n" "$sanitized_title" >&2
    fi
}

# Function to remove extra songs that are not in the playlist
clean_extra_songs() {
    local playlist_titles="$1"
    local download_dir="$2"
    local filename
    while IFS= read -r file; do
        filename=$(basename "$file" .mp3)
        if ! grep -Fxq "$filename" <<< "$playlist_titles"; then
            printf "Deleting extra song: %s\n" "$file"
            rm -f "$file"
        fi
    done < <(find "$download_dir" -type f -name "*.mp3")
}

# Function to update a playlist
update_playlist() {
    local playlist_name="$1"
    local playlist_url="$2"
    local download_dir="$BASE_DIR/$playlist_name"

    mkdir -p "$download_dir"

    local playlist_data
    if ! playlist_data=$(get_playlist_songs "$playlist_url"); then
        return
    fi

    local playlist_titles=""
    
    while IFS='|' read -r song_title song_url; do
        [[ -z "$song_title" || -z "$song_url" ]] && continue

        local sanitized_title; sanitized_title=$(sanitize_filename "$song_title")
        playlist_titles+="$sanitized_title"$'\n'

        if song_exists_locally "$sanitized_title" "$download_dir"; then
            printf "Skipping (already exists): %s\n" "$sanitized_title"
            continue
        fi

        download_song "$song_url" "$sanitized_title" "$download_dir"
    done <<< "$playlist_data"

    clean_extra_songs "$playlist_titles" "$download_dir"
}

# Main function
main() {
    declare -A SELECTED_PLAYLISTS

    printf "Select playlists to update:\n"
    for playlist_name in "${!PLAYLISTS[@]}"; do
        printf "Update '%s'? (y/n): " "$playlist_name"
        read -r choice
        if [[ "$choice" =~ ^[Yy]$ ]]; then
            SELECTED_PLAYLISTS["$playlist_name"]="${PLAYLISTS[$playlist_name]}"
        fi
    done

    if [[ ${#SELECTED_PLAYLISTS[@]} -eq 0 ]]; then
        printf "No playlists selected. Exiting.\n"
        return
    fi

    for playlist_name in "${!SELECTED_PLAYLISTS[@]}"; do
        update_playlist "$playlist_name" "${SELECTED_PLAYLISTS[$playlist_name]}"
    done
}

main
