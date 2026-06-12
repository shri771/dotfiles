{
  config,
  lib,
  pkgs,
  ...
}:

let
  dotfiles = "${config.home.homeDirectory}/dotfiles";

  # Helper to create out-of-store symlinks
  mkLink = name: {
    source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/${name}";
  };

  # List of directories/files in ~/dotfiles to link into ~/.config
  configApps = [
    "evremap"
    "hypr"
    "rofi"
    "wallust"
    "cava"
    "fusuma"
    "Kvantum"
    "picom"
    "starship.toml"
    "waybar"
    "alacritty"
    "polybar"
    "fish"
    "wlogout"
    "swappy"
    "awesome"
    "swaync"
    "nvim"
    "kanshi"
    "fastfetch"
    "ags"
    "eww"
    "tmux"
    "greenclip.toml"
    "mpd"
    "kitty"
    "ranger"
    "yazi"
  ];
in
{
  # --- 1. THE CONFIG SYMLINKS ---
  # Automatically generate symlinks for all apps in the list
  xdg.configFile = lib.genAttrs configApps mkLink // {
    "pypr/config.toml".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/hypr/pyprland.toml";
  };

  # --- 2. PACKAGES (TMUX & TMUXIFIER) ---
  home.packages = with pkgs; [
    tmux
    tmuxifier
  ];

  # --- 3. TMUXIFIER LAYOUTS ---
  home.file.".tmuxifier/layouts".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/scripts/tmuxifier";
}
