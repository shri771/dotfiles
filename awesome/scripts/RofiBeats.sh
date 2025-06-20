#!/bin/bash

# Directory local music base folder
BASE_DIR="$HOME/Downloads/Music"

# Directory for icons
ICON_DIR="$HOME/.config/swaync/icons"

# Function for displaying notifications
notification() {
  notify-send -u normal -i "$ICON_DIR/music.png" " Now Playing:" "$@"
}

# Function to select a folder
select_music_folder() {
  local folder_choice
  folder_choice=$(find "$BASE_DIR" -mindepth 1 -maxdepth 1 -type d -printf "%f\n" | \
    rofi -dmenu -i -config ~/.config/rofi/config-rofi-Beats.rasi -p "Select Music Folder" \
    -kb-move-up "Control+p" -kb-move-down "Control+n")

  [[ -z "$folder_choice" ]] && return 1
  echo "$BASE_DIR/$folder_choice"
}

# Function for playing local music (shuffle play selected folder)
play_local_music() {
  local selected_folder basename_folder

  selected_folder=$(select_music_folder) || return 1
  basename_folder=$(basename "$selected_folder")
  notification "$basename_folder"

  # Stop currently playing media if any
  if command -v playerctl &>/dev/null; then
    if playerctl status &>/dev/null && [[ $(playerctl status) == "Playing" ]]; then
      playerctl stop
    fi
  fi

  # Launch VLC with metadata and random loop
  if command -v vlc &>/dev/null; then
    vlc --meta-title "My Music Player 🎵" --random --loop "$selected_folder"/*
  else
    echo "VLC is not installed or not in PATH" >&2
    return 1
  fi
}

# Stop music if VLC is running, otherwise show menu
pkill vlc && notify-send -u low -i "$ICON_DIR/music.png" "Music stopped" || {
  if pidof rofi >/dev/null; then
    pkill rofi
  fi

  play_local_music
}
