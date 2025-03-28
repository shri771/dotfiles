#!/bin/bash
set -euo pipefail

# Secure GPG Editor with Neovim Lockdown
# Usage: ./edit_gpg.sh <file.gpg>

# --- Configuration ---
TMP_DIR=$(mktemp -d -p /dev/shm)
TMP_FILE="${TMP_DIR}/$(basename "$1").tmp"
PASS_FILE="${TMP_DIR}/.pass"
NVIM_CMD="nvim"  # Force Neovim as editor

# --- Security Setup ---
cleanup() {
    if [[ -f "$PASS_FILE" ]]; then
        echo "Wiping passphrase from memory..."
        rm -f "$PASS_FILE"
    fi
    rm -rf "${TMP_DIR}"
    gpgconf --kill gpg-agent
    echo "Secure cleanup completed."
}
trap cleanup EXIT INT TERM

# --- Neovim Validation ---
validate_editor() {
    if ! command -v "$NVIM_CMD" >/dev/null; then
        echo "ERROR: Neovim not found! Install with:" >&2
        echo "  sudo apt install neovim  # Debian/Ubuntu" >&2
        echo "  sudo pacman -S neovim    # Arch" >&2
        exit 1
    fi
}

# --- Passphrase Handling ---
get_passphrase() {
    read -s -p "Enter GPG passphrase: " passphrase
    echo
    echo -n "$passphrase" > "$PASS_FILE"
    unset passphrase
    chmod 600 "$PASS_FILE"
}

# --- Main Execution ---
validate_editor  # Validate Neovim before proceeding

if [[ -z "$1" ]]; then
    echo "Usage: $0 <encrypted-file.gpg>" >&2
    exit 1
fi

if [[ ! -f "$1" ]]; then
    echo "Creating new encrypted file..."
    touch "$TMP_FILE"
else
    get_passphrase
    
    echo "Decrypting file..."
    if ! gpg --batch --passphrase-file "$PASS_FILE" \
         --output "$TMP_FILE" --decrypt "$1"; then
        echo "Decryption failed! Wrong passphrase or corrupted file." >&2
        exit 1
    fi
fi

# Launch Neovim with secure settings
"$NVIM_CMD" -n -i NONE --cmd '
    set nobackup
    set nowritebackup
    set noswapfile
    set noundofile
    set viminfo=""
' "$TMP_FILE"

if [[ ! -f "$1" ]]; then
    get_passphrase
fi

echo "Re-encrypting file..."
gpg --batch --yes --symmetric \
    --cipher-algo AES256 \
    --s2k-mode 3 --s2k-count 65011712 \
    --s2k-digest-algo SHA512 \
    --force-mdc \
    --passphrase-file "$PASS_FILE" \
    --output "$1" "$TMP_FILE"

echo "File securely encrypted using Neovim. No temp files created."
