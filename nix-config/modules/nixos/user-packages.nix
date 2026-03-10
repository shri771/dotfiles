{ pkgs, ... }:

{
  # Common packages for all interactive users on the system
  environment.systemPackages = with pkgs; [
    # Core Utilities
    gitFull
    curl
    jq
    unzip
    tmux
    evremap
    trash-cli
    home-manager

    # Shell & Terminal
    fish
    starship
    zoxide
    eza
    carapace
    fzf
    kitty

    # Desktop Applications
    brave
    vivaldi
    kdePackages.kate
    neovim # Also in configuration.nix, but listed here for completeness

    # Auth & Security
    gnome-keyring
    seahorse
    libsecret
    polkit

    # Hardware & Theming
    openrgb-with-all-plugins
    noto-fonts
    noto-fonts-color-emoji
    
    # Window Managers (Binaries)
    awesome
    hyprland
  ];
}
