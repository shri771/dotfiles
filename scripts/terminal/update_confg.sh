#!/bin/bash

# Define paths
DOTFILES_DIR=~/dotfiles/config
AWESOME_CONFIG=~/.config/awesome
FISH_CONFIG=~/.config/fish

# Ensure the target directory exists
mkdir -p "$DOTFILES_DIR"

# Move Awesome WM configuration
if [ -d "$AWESOME_CONFIG" ]; then
  echo "Replacing Awesome WM config in $DOTFILES_DIR..."
  rm -rf "$DOTFILES_DIR/awesome" # Remove existing directory in dotfiles
  mv "$AWESOME_CONFIG" "$DOTFILES_DIR/awesome"
  echo "Moved $AWESOME_CONFIG to $DOTFILES_DIR/awesome"
else
  echo "No Awesome WM config found at $AWESOME_CONFIG"
fi

# Move Fish shell configuration
if [ -d "$FISH_CONFIG" ]; then
  echo "Replacing Fish config in $DOTFILES_DIR..."
  rm -rf "$DOTFILES_DIR/fish" # Remove existing directory in dotfiles
  mv "$FISH_CONFIG" "$DOTFILES_DIR/fish"
  echo "Moved $FISH_CONFIG to $DOTFILES_DIR/fish"
else
  echo "No Fish config found at $FISH_CONFIG"
fi

# Navigate to dotfiles directory
cd ~/dotfiles || {
  echo "dotfiles directory not found!"
  exit 1
}

# Git add, commit, and push
echo "Adding changes to Git..."
git add config
git commit -m "Updated config"
git push

echo "Dotfiles updated and pushed successfully!"
