#!/usr/bin/env bash

# A unified Rofi launcher for MPD playlist management and controls.

ROFI_CONFIG="/home/sh/dotfiles/rofi/config-rofi-Beats.rasi"
MUSIC_DIR="/home/sh/Downloads/Music"
ICON_PATH="/home/sh/.icons/Mkos-Big-Sur-Night/128x128@2x/apps/com.googleplaymusicdesktopplayer.GPMDP.svg"

# Function to allow the user to select and play a playlist from a directory
select_and_play_playlist() {
    local playlist
    playlist=$(find "$MUSIC_DIR" -mindepth 1 -maxdepth 1 -type d -printf "%f\n" |
        rofi -dmenu -i -config "$ROFI_CONFIG" -p "Select Playlist")

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
    local list_row='5'

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

    local active=''
    local urgent=''

    # No background for repeat entry.
    # Background for playlist entry is based on random state.
    if [[ $status == *"random: on"* ]]; then
        active="-a 6"
    elif [[ $status == *"random: off"* ]]; then
        urgent="-u 6"
    fi

    local chosen
    chosen=$(
        echo -e "$option_1\n$option_2\n$option_3\n$option_4\n$option_5\n$option_6" | rofi \
            -dmenu \
            -i \
            -p "$prompt" \
            -mesg "$mesg" \
            ${active} ${urgent} \
            -markup-rows \
            -config "$ROFI_CONFIG" \
            -theme-str "listview {columns: $list_col; lines: $list_row;}" \
            -theme-str 'textbox-prompt-colon {str: "";}' \
            -theme-str 'element normal.active { background-color: #A6E3A1; text-color: #1E1E2E; }' \
            -theme-str 'element selected.active { background-color: #A6E3A1; text-color: #1E1E2E; }' \
            -theme-str 'element normal.urgent { background-color: #F38BA8; text-color: #1E1E2E; }'
    )

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
    esac
}

# Run the main controls UI
show_mpd_controls
