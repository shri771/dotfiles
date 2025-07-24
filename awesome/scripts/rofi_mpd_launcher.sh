#!/usr/bin/env bash

# A unified Rofi launcher for MPD playlist management and controls.

ROFI_CONFIG="/home/sh/dotfiles/rofi/config-rofi-Beats.rasi"
MUSIC_DIR="/home/sh/Downloads/Music"
ICON_PATH="/home/sh/.icons/Mkos-Big-Sur-Night/128x128@2x/apps/com.googleplaymusicdesktopplayer.GPMDP.svg"

# Function to display a sub-menu for updating YouTube Music playlists
show_update_menu() {
    local update_script="/home/sh/dotfiles/scripts/system/YT_music_update_rofi.sh"
    local update_options="Cheerful\nFeel-Good💖\nRemix\nCurrent\ntest\nall"

    local chosen_update
    chosen_update=$(echo -e "$update_options" | rofi -dmenu -i -p "Select Update Option")

    if [ -n "$chosen_update" ]; then
        "$update_script" "$chosen_update"
    fi
}

# Function to allow the user to select and play a playlist from a directory
select_and_play_playlist() {
    local playlist
    playlist=$(find "$MUSIC_DIR" -mindepth 1 -maxdepth 1 -type d -printf "%f\n" |
        rofi -dmenu -i -p "Select Playlist")

    if [ -n "$playlist" ]; then
        playerctl pause
        mpc clear
        mpc add "$playlist"
        mpc shuffle
        mpc play
        notify-send -i "$ICON_PATH" "MPD" "Playing playlist: $playlist"
    fi
}

# Main function to display MPD controls
show_mpd_controls() {
    local status
    status=$(mpc status)

    local prompt mesg
    if [[ -z "$status" ]]; then
        prompt='Offline'
        mesg="MPD is Offline"
    else
        prompt="$(mpc -f "%artist%" current)"
        local current_song_path playlist_name
        current_song_path=$(mpc -f %file% current)
        mesg="$(mpc -f "%title%" current) :: $(mpc status | grep "#" | awk '{print $3}')"

        if [ -n "$current_song_path" ]; then
            playlist_name=$(basename "$(dirname "$current_song_path")")
            if [ "$playlist_name" != "." ] && [ "$playlist_name" != "Music" ]; then
                mesg="$mesg :: $playlist_name"
            fi
        fi
    fi

    local list_col='1'
    local list_row='5' # Increased to accommodate the new option

    local option_1 option_2 option_3 option_4 option_5 option_6 option_7
    if [[ $status == *"[playing]"* ]]; then
        option_1=" Pause"
    else
        option_1=" Play"
    fi
    option_2=" Stop"
    option_3=" Previous"
    option_4=" Next"
    option_5=" Repeat"
    option_6=" Playlists"
    option_7=" Update" # New option

    local chosen exit_code
    chosen=$(
        echo -e "$option_1\n$option_4\n$option_3\n$option_2\n$option_5\n$option_6\n$option_7" |
            rofi -dmenu -i -p "$prompt" -mesg "$mesg" \
                -markup-rows \
                -theme-str "listview {columns: $list_col; lines: $list_row;}"
    )
    exit_code=$?

    # Exit on any Rofi error or cancel to avoid looping on config issues
    if [ $exit_code -ne 0 ]; then
        exit
    fi

    playlist_length=$(mpc playlist | wc -l)

    case "$chosen" in
    "$option_1") # Play/Pause
        if [[ $status == *"[playing]"* ]]; then
            mpc -q pause
            notify-send -i "$ICON_PATH" -u low -t 1000 " Paused"
        elif [[ $status == *"[paused]"* ]]; then
            playerctl pause
            mpc -q play
            notify-send -i "$ICON_PATH" -u low -t 1000 " $(mpc current)"
        else # stopped
            if [ "$playlist_length" -gt 0 ]; then
                playerctl pause
                mpc -q play 1
                notify-send -i "$ICON_PATH" -u low -t 1000 " $(mpc current)"
            else
                select_and_play_playlist
            fi
        fi
        ;;
    "$option_2") mpc -q stop ;;
    "$option_3") # Previous
        if [ "$playlist_length" -gt 0 ]; then
            mpc -q prev
            if [[ $status != *"[playing]"* ]]; then
                playerctl pause
                mpc -q play
            fi
            notify-send -i "$ICON_PATH" -u low -t 1000 " $(mpc current)"
        else
            select_and_play_playlist
        fi
        ;;
    "$option_4") # Next
        if [ "$playlist_length" -gt 0 ]; then
            mpc -q next
            if [[ $status != *"[playing]"* ]]; then
                playerctl pause
                mpc -q play
            fi
            notify-send -i "$ICON_PATH" -u low -t 1000 " $(mpc current)"
        else
            select_and_play_playlist
        fi
        ;;
    "$option_5") mpc -q repeat ;;
    "$option_6") select_and_play_playlist ;;
    "$option_7") show_update_menu ;; # Handle the new Update option
    esac
}

# Run the main controls UI
show_mpd_controls
