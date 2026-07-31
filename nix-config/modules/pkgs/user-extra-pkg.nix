{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  # Initialize the unstable channel
  unstable = import inputs.nixpkgs-unstable {
    system = pkgs.stdenv.hostPlatform.system;
    config.allowUnfree = true;
  };
  androidSdk = pkgs.androidenv.composeAndroidPackages {
    platformVersions = [ "34" ];
    buildToolsVersions = [ "34.0.0" ];
    includeNDK = false;
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
    wineWow64Packages.waylandFull
    wineWow64Packages.fonts
    winetricks
    bottles

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

    google-chrome

    ## Android Dev
    androidSdk.androidsdk
    flutter
  ];
}
