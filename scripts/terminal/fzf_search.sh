#!/usr/bin/env bash
#
# fzf-nvim.sh — pop up an fzf chooser in tmux, cd into your choice, then nvim it.

# -----------------------------------------------------------------------------
# 1) Detect tmux session
# -----------------------------------------------------------------------------
session=$(tmux display-message -p '#S' 2>/dev/null)
if [[ -z "$session" ]]; then
  echo "❌ Not running inside tmux."
  exit 1
fi

# -----------------------------------------------------------------------------
# 2) Set your base directory per session name
# -----------------------------------------------------------------------------
case "$session" in
  cn) base="$HOME/dotfiles" ;;
  dev) base="$HOME/WorkSpace/158309813" ;;
  *)
    echo "❌ Unrecognized tmux session: $session"
    exit 1
    ;;
esac

# -----------------------------------------------------------------------------
# 3) Change into base dir and run fzf in a centered tmux popup
# -----------------------------------------------------------------------------
cd "$base" || { echo "❌ Cannot cd into $base"; exit 1; }

chosen=$(find . -maxdepth 1 -mindepth 1 -type d \
         | sed 's|^\./||' \
         | fzf \
             --tmux="center,60%,70%" \
             --border )

# If nothing selected, exit quietly
if [[ -z "$chosen" ]]; then
  exit 0
fi

# -----------------------------------------------------------------------------
# 4) Jump into the selection and open Neovim
# -----------------------------------------------------------------------------
cd "$chosen" || exit 1
exec nvim .
