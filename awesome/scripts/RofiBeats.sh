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
  selected_folder=$(select_music_folder) || exit 1

  basename_folder=$(basename "$selected_folder")
  notification "$basename_folder"

  playerctl stop && vlc --meta-title "My Music Player 🎵" --random --loop "$selected_folder"/*
}

# Stop music if VLC is running, otherwise show menu
pkill vlc && notify-send -u low -i "$ICON_DIR/music.png" "Music stopped" || {
  if pidof rofi >/dev/null; then
    pkill rofi
  fi

  play_local_music
}
