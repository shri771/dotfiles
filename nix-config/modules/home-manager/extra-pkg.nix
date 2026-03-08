{ config, lib, pkgs, inputs, ... }:

let
  # Initialize the unstable channel
  unstable = import inputs.nixpkgs-unstable {
    system = pkgs.system;
    config.allowUnfree = true;
  };
in
{
  home.packages = with pkgs; [
    # --- Media & Video ---
    ffmpeg
    obs-studio
    mpd
    cantata

    # --- CLI & Core Utilities ---
    btop
    powertop

    # --- Reading & Documents ---
    foliate
    calibre
    pandoc
    marksman
    glow
    libreoffice-qt

    # --- Apps & GUI Tools ---
    wireshark
    eog
    feh
    sxiv
    krita
    krusader
    gnome-boxes
    virt-manager
    easyeffects

    # --- Development & Containers ---
    lazydocker
    postman
    temporal-cli

    # --- Networking & Security ---
    gpg-tui

    # --- Miscellaneous ---
    cowsay
    flatpak
    nginx
    rustc
    sox
    translate-shell
    typescript
    variety
    ostree

    # --- Unstable Packages ---
    unstable.opencode
    unstable.gemini-cli
    unstable.antigravity
  ];
}
