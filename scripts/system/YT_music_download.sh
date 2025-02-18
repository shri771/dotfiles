
#!/bin/bash
# YouTube Music Downloader using yt-dlp with user-defined directory handling

set -euo pipefail

# Ensure yt-dlp is installed
check_dependencies() {
    if ! command -v yt-dlp &>/dev/null; then
        printf "Error: 'yt-dlp' is not installed. Please install it.\n" >&2
        return 1
    fi
}

# Prompt user for folder name
get_download_path() {
    local base_path="$HOME/Downloads/Music"
    local folder_name

    read -r -p "Enter folder name for download (default: 'Feel'): " folder_name
    folder_name="${folder_name:-Feel}"
    
    printf "%s/%s\n" "$base_path" "$folder_name"
}

# Prompt user for custom download path
get_custom_download_path() {
    local path
    read -r -p "Enter full download path: " path
    [[ -z "$path" ]] && return 1
    printf "%s\n" "$path"
}

# Prompt user for the YouTube Music link
get_download_link() {
    local link
    read -r -p "Enter the YouTube Music playlist or video link: " link
    [[ -z "$link" ]] && return 1
    printf "%s\n" "$link"
}

# Perform download
download_music() {
    local path=$1
    local link=$2

    mkdir -p "$path"

    yt-dlp -f bestaudio --extract-audio --audio-format mp3 --audio-quality 0 \
        --embed-thumbnail --embed-metadata --parse-metadata "thumbnail:%(meta_thumbnail)s" \
        -o "${path}/%(title)s.%(ext)s" "$link"
}

main() {
    check_dependencies || exit 1

    local download_path link

    if [[ $# -gt 0 && $1 == "-n" ]]; then
        download_path=$(get_custom_download_path) || exit 1
    else
        download_path=$(get_download_path)
    fi

    link=$(get_download_link) || exit 1

    download_music "$download_path" "$link"
}

main "$@"
