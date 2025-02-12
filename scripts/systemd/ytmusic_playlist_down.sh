#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

# Default download directories
DIR_FEEL="$HOME/Downloads/Music/Feel-Good/"
DIR_CHEERFUL="$HOME/Downloads/Music/Cheerful/"

# Playlist URLs
URL_FEEL="https://music.youtube.com/playlist?list=PLOlHDApPp3YtOYIj_1S_NSBLavu9JsoNY&si=OeXCn6dT_ESl_Ij-"
URL_CHEERFUL="https://music.youtube.com/playlist?list=PLOlHDApPp3YvM3Ov9rnFCrT5jha8DWVGu&si=w9nuUohejfpuMB83"

# Function to sanitize filenames and prevent long filenames
sanitize_filename() {
    local name="$1"
    name=$(printf "%s" "$name" | tr -d '\n' | sed 's/[^a-zA-Z0-9._-]/_/g')

    # Ensure the filename is within the system limits (max 200 characters)
    local max_length=200
    if [[ ${#name} -gt $max_length ]]; then
        name="${name:0:$max_length}"
    fi

    printf "%s" "$name"
}

# Function to get playlist song names with URLs
get_playlist_songs() {
    local url="$1"
    yt-dlp --flat-playlist --print "%(title)s|%(id)s" "$url" 2>/dev/null
}

# Function to sync playlist: download missing songs and remove deleted ones
sync_playlist() {
    local url="$1"
    local dir="$2"

    mkdir -p "$dir"

    # Fetch current playlist songs
    local playlist_data; playlist_data=$(get_playlist_songs "$url")

    if [[ -z "$playlist_data" ]]; then
        printf "Error: Unable to fetch playlist songs. Skipping.\n" >&2
        return 1
    fi

    # Parse song titles and IDs
    declare -A playlist_map
    while IFS="|" read -r title video_id; do
        local sanitized_title; sanitized_title=$(sanitize_filename "$title")
        playlist_map["$sanitized_title"]="$video_id"
    done <<< "$playlist_data"

    # Get existing local song files
    local existing_songs; existing_songs=$(find "$dir" -type f -name "*.mp3" -exec basename {} .mp3 \; | sort -u)

    # Download only missing songs
    for song in "${!playlist_map[@]}"; do
        local video_id="${playlist_map[$song]}"
        local output_file="$dir/$song.mp3"

        if [[ -f "$output_file" ]]; then
            printf "Skipping download (already exists): %s\n" "$song"
            continue
        fi

        printf "Downloading: %s\n" "$song"
        if ! yt-dlp -f bestaudio --extract-audio --audio-format mp3 --audio-quality 0 \
            -o "$output_file" "https://music.youtube.com/watch?v=$video_id"; then
            printf "Error: Failed to download %s\n" "$song" >&2
        fi
    done

    # Remove outdated local files not in the playlist
    for obsolete_song in $existing_songs; do
        if [[ -z "${playlist_map[$obsolete_song]+_}" ]]; then
            local obsolete_file="$dir/$obsolete_song.mp3"
            printf "Removing outdated song: %s\n" "$obsolete_song"
            rm -f "$obsolete_file"
        fi
    done
}

# Main execution flow
main() {
    local choice
    printf "Do you want to update your playlists? [Y/n]: "
    read -r choice
    choice=${choice:-Y}

    if [[ "$choice" =~ ^[Yy]$ ]]; then
        sync_playlist "$URL_FEEL" "$DIR_FEEL"
        sync_playlist "$URL_CHEERFUL" "$DIR_CHEERFUL"
    fi
}

main
