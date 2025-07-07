#!/usr/bin/env bash

# Global Variables
BASE_DIR="$HOME/Downloads/Music"
ICON_PATH="/home/sh/.icons/Mkos-Big-Sur-Night/128x128@2x/apps/com.googleplaymusicdesktopplayer.GPMDP.svg"
declare -A PLAYLISTS=(
    ["Cheerful"]="https://music.youtube.com/playlist?list=PLOlHDApPp3YvM3Ov9rnFCrT5jha8DWVGu"
    ["Feel-Good💖"]="https://music.youtube.com/playlist?list=PLOlHDApPp3YtOYIj_1S_NSBLavu9JsoNY"
    ["Remix"]="https://music.youtube.com/playlist?list=PLOlHDApPp3Yu68BquCuanfY5VOF4dFBk7"
    ["Current"]="https://music.youtube.com/playlist?list=PLOlHDApPp3YtW4ZLuuP7cXFKBqAKI4ALP"
    ["test"]="https://music.youtube.com/playlist?list=PLOlHDApPp3YuiVbdN0G-ESyZGNA5_t0cA"
)

# --- Helper Functions ---

# Function to display help message
show_help() {
    printf "Usage: %s [options] [playlist...]\n" "$(basename "$0")"
    printf "Update local music playlists from YouTube Music.\n\n"
    printf "Options:\n"
    printf "  -h, --help    Show this help message and exit.\n\n"
    printf "Arguments:\n"
    printf "  playlist      One or more playlist names to update.\n"
    printf "                Available playlists: %s\n" "${!PLAYLISTS[*]}"
    printf "  all           A special argument to update all available playlists.\n\n"
    printf "If no arguments are provided, a Rofi menu will be shown to select a playlist.\n"
}

# Function to sanitize filenames
sanitize_filename() {
    local filename="$1"
    filename=$(printf '%s' "$filename" | sed "s|[/:*?\"'<>|]|_|g")
    printf '%s' "$filename"
}

# --- Core Music Functions ---

# Function to get playlist song titles and URLs
get_playlist_songs() {
    local playlist_url="$1"
    local output
    if ! output=$(yt-dlp --flat-playlist --print "%(title)s|%(url)s" "$playlist_url" 2>/dev/null); then
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
    local output_path="$download_dir/$sanitized_title"

    printf "Downloading: %s\n" "$sanitized_title"
    if ! yt-dlp --ignore-errors -f bestaudio --extract-audio --audio-format mp3 --audio-quality 0 \
        --write-thumbnail --no-embed-thumbnail --add-metadata \
        -o "$output_path" "$song_url" >/dev/null 2>&1; then
        printf "Download failed for: %s (likely unavailable or restricted)\n" "$sanitized_title" >&2
    fi
}

# Function to process and embed thumbnails
process_thumbnails() {
    local download_dir="$1"
    shopt -s nullglob
    for mp3 in "$download_dir"/*.mp3; do
        base="${mp3%.mp3}"
        thumb=""
        for ext in webp jpg jpeg png; do
            [[ -f "${base}.${ext}" ]] && thumb="${base}.${ext}" && break
        done
        if [[ -z "$thumb" ]]; then
            echo "⚠️  No thumbnail for '$(basename "$mp3")', skipping."
            continue
        fi

        echo "   • Embedding cover into $(basename "$mp3")"
        proc="${base}.crop.jpg"

        ffmpeg -y -i "$thumb" \
            -vf "scale=800:800:force_original_aspect_ratio=increase,crop=800:800" \
            -frames:v 1 -update 1 \
            "$proc"

        tmp="${base}.tmp.mp3"
        ffmpeg -y \
            -i "$mp3" -i "$proc" \
            -map 0:a -map 1:v \
            -c:a copy -c:v mjpeg \
            -id3v2_version 3 \
            "$tmp"

        mv "$tmp" "$mp3"
    done

    find "$download_dir" -type f \( -iname '*.webp' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' \) -delete
}

# Function to remove extra songs that are not in the playlist
clean_extra_songs() {
    local playlist_titles="$1"
    local download_dir="$2"

    # Safety check: if playlist_titles is empty, do not proceed.
    if [ -z "$playlist_titles" ]; then
        printf "Warning: Playlist is empty. Skipping cleanup to prevent accidental deletion.\n"
        return
    fi

    while IFS= read -r file; do
        local filename; filename=$(basename "$file" .mp3)
        # Remove the .%(ext)s suffix before comparing
        filename=${filename%%.%(ext)s}
        if ! grep -Fxq "$filename" <<< "$playlist_titles"; then
            printf "Deleting extra song: %s\n" "$file"
            rm -f "$file"
        fi
    done < <(find "$download_dir" -type f -name "*.mp3")
}

# Function to update a playlist
update_playlist() {
    local playlist_name="$1"
    local playlist_url="${PLAYLISTS[$playlist_name]}"
    local download_dir="$BASE_DIR/$playlist_name"

    if [ -z "$playlist_url" ]; then
        printf "Error: Playlist '%s' not found.\n" "$playlist_name" >&2
        return 1
    fi

    printf "\n--- Updating Playlist: %s ---\n" "$playlist_name"
    mkdir -p "$download_dir"

    local playlist_data
    if ! playlist_data=$(get_playlist_songs "$playlist_url"); then
        return
    fi

    local playlist_titles=""

    while IFS='|' read -r song_title song_url; do
        [[ -z "$song_title" || -z "$song_url" ]] && continue

        local sanitized_title; sanitized_title=$(sanitize_filename "$song_title")
        playlist_titles+="$sanitized_title"$'
'

        if song_exists_locally "$sanitized_title" "$download_dir"; then
            printf "Skipping (already exists): %s\n" "$sanitized_title"
            continue
        fi

        download_song "$song_url" "$sanitized_title" "$download_dir"
    done <<< "$playlist_data"

    echo "→ Processing and embedding cover art…"
    process_thumbnails "$download_dir"
    clean_extra_songs "$playlist_titles" "$download_dir"
}

# --- Main Logic ---

main() {
    # If not running inside the specific tmux session/window, re-execute in tmux
    if [[ -z "$TMUX" || "$(tmux display-message -p '#S:#W')" != "cn:Yt_down" ]]; then
        notify-send -i "$ICON_PATH" "YouTube Music Update" "Opening update in new tmux window (cn:Yt_down)..."
        tmux new-session -d -s cn 2>/dev/null || true # Create session if it doesn't exist, and keep it detached
        tmux new-window -t cn: -n Yt_down 2>/dev/null || true # Create window in the detached session, without switching to it
        tmux send-keys -t cn:Yt_down "bash $(readlink -f "$0") $@ && exit" C-m
        exit 0
    fi

    # Handle --help flag
    if [[ "$1" == "--help" || "$1" == "-h" ]]; then
        show_help
        exit 0
    fi

    # If arguments are provided, use them
    if [ "$#" -gt 0 ]; then
        notify-send -i "$ICON_PATH" "YouTube Music Update" "Starting update for: $@..."
        if [[ "$1" == "all" ]]; then
            for playlist_name in "${!PLAYLISTS[@]}"; do
                update_playlist "$playlist_name"
            done
        else
            for playlist_name in "$@"; do
                update_playlist "$playlist_name"
            done
        fi
        notify-send -i "$ICON_PATH" "YouTube Music Update" "Update complete for: $@."
        exit 0
    fi

    # If no arguments, show Rofi menu
    local options
    options=$(printf "%s\n" "${!PLAYLISTS[@]}" "all")
    
    local chosen
    chosen=$(echo -e "$options" | rofi -dmenu -p "Select Playlist to Update")

    if [ -n "$chosen" ]; then
        notify-send "YouTube Music Update" "Starting update for: $chosen..."
        if [[ "$chosen" == "all" ]]; then
            for playlist_name in "${!PLAYLISTS[@]}"; do
                update_playlist "$playlist_name"
            done
        else
            update_playlist "$chosen"
        fi
        notify-send "YouTube Music Update" "Update complete for: $chosen."
    else
        printf "No playlist selected. Exiting.\n"
    fi
}

main "$@"