{ config, lib, pkgs, ... }:

let
  dotfiles = "${config.home.homeDirectory}/dotfiles";
in
{
  # --- 1. THE CONFIG SYMLINKS ---
  xdg.configFile = {
    "evremap".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/evremap";
    "hypr".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/hypr";
    "rofi".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/rofi";
    "wallust".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/wallust";
    "cava".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/cava";
    "fusuma".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/fusuma";
    "Kvantum".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/Kvantum";
    "picom".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/picom";
    "starship.toml".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/starship.toml";
    "waybar".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/waybar";
    "alacritty".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/alacritty";
    "polybar".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/polybar";
    "fish".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/fish";
    "btop".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/btop";
    "wlogout".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/wlogout";
    "swappy".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/swappy";
    "awesome".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/awesome";
    "swaync".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/swaync";
    "nvim".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/nvim";
    "kanshi".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/kanshi";
    "dolphinrc".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/dolphinrc";
    "assets".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/assets";
    "fastfetch".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/fastfetch";
    "ags".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/ags";
    "eww".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/eww";
    "tmux".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/tmux";
    "greenclip.toml".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/greenclip.toml";
    "mpd".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/mpd";
    "kitty".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/kitty";
  };

  # --- 2. PACKAGES (TMUX & TMUXIFIER) ---
  # Installing tmux here guarantees Nix won't try to manage or overwrite your tmux.conf
  home.packages = with pkgs; [
    tmux
    tmuxifier
  ];

  # --- 3. TMUXIFIER LAYOUTS ---
  # Symlink the tmuxifier layouts directory
  home.file.".tmuxifier/layouts".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/scripts/tmuxifier";
}
