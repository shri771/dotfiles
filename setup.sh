#!/bin/bash

# Define the source and target directories
DOTFILES_DIR=$(dirname "$(realpath "$0")")
CONFIG_DIR="$HOME/.config"
SYMLINKS_FILE="$DOTFILES_DIR/symlinks.txt"

# Read the list of configuration directories to symlink from the file
if [ -f "$SYMLINKS_FILE" ]; then
  mapfile -t CONFIGS < "$SYMLINKS_FILE"
else
  echo "Symlinks file not found at $SYMLINKS_FILE"
  exit 1
fi

# Iterate over each config directory
for config in "${CONFIGS[@]}"; do
  # Remove quotes from the config name
  config="${config//\"/}"
  SOURCE="$DOTFILES_DIR/$config"
  TARGET="$CONFIG_DIR/$config"


  # Check if the directory exists in ~/.config
  if [ -d "$TARGET" ]; then
    echo "Directory $TARGET exists. Removing and creating symlink."
    rm -rf "$TARGET"
  fi

  # Check if the source exists in the dotfiles directory
  if [ -e "$SOURCE" ]; then
    # Create the symlink
    echo "Creating symlink: $TARGET -> $SOURCE"
    ln -s "$SOURCE" "$TARGET"
  else
    echo "Source $SOURCE does not exist. Skipping."
  fi
done

echo "Symlink creation process completed."

# Ask user if they want to setup tmux
read -p "Do you want to set up tmux (install tpm)? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    echo "Setting up tmux..."
    TMUX_PLUGIN_DIR="$CONFIG_DIR/tmux/plugins/tpm"
    if [ ! -d "$TMUX_PLUGIN_DIR" ]; then
        echo "Cloning tpm (tmux plugin manager) into $TMUX_PLUGIN_DIR"
        git clone https://github.com/tmux-plugins/tpm "$TMUX_PLUGIN_DIR"
        echo "tpm cloned successfully. Start tmux and press Prefix + I to install plugins."
    else
        echo "tpm is already present at $TMUX_PLUGIN_DIR. Skipping cloning."
    fi
else
    echo "Skipping tmux setup."
fi

