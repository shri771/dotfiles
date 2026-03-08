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
    wf-recorder
    losslesscut-bin
    mpv
    cava
    mpc
    ncmpcpp

    # --- CLI & Core Utilities ---
    gnumake
    psmisc
    ripgrep # Fixes Telescope error
    jq
    gcc
    htop
    bat
    acpi
    bc
    corectrl
    fastfetch
    fd
    lsof
    tree
    wget
    curl
    plocate
    pv
    stress-ng
    sysbench
    tlp
    trash-cli
    usbutils
    zbar

    # --- System & Hardware ---
    brightnessctl
    pamixer
    pavucontrol
    polkit
    polkit_gnome
    blueman
    bluez-tools
    networkmanagerapplet
    os-prober
    gparted
    dosfstools
    nvme-cli
    libinput


    # --- UI & Desktop Environment (Hyprland/Wayland) ---
    rofi
    alacritty
    kitty
    hypridle
    hyprland
    hyprlock
    hyprpolkitagent
    pyprland
    waybar
    wlogout
    swappy
    swaybg
    swayimg
    swaynotificationcenter
    swww
    xdg-desktop-portal-hyprland
    kanshi
    nwg-displays
    nwg-look
    cliphist
    wl-clipboard
    batsignal

    # --- X11 Utilities (Fallback/Tools) ---
    arandr
    i3blocks
    lxappearance
    nitrogen
    numlockx
    picom
    polybar
    sxhkd
    xclip
    xdotool
    xorg.xinit
    xss-lock
    ydotool

    # --- Apps & GUI Tools ---
    qrencode
    flameshot
    shotwell
    loupe
    qalculate-gtk
    nemo
    kdePackages.filelight

    # --- Development & Containers ---
    nodejs
    docker
    minikube
    kubectl
    kubernetes-helm
    gh
    cmake
    meson
    flex
    sqlite
    postgresql
    direnv
    dysk

    # --- Go Language & LSP ---
    go
    gopls
    (lib.lowPrio gotools)
    golangci-lint
    delve
    sqls
    gofumpt

    # --- Python ---
    python3
    pipx
    uv

    # --- Networking & Security ---
    nmap
    hashcat
    john
    encfs
    gnupg
    pinentry-gnome3
    seahorse
    conntrack-tools
    tor
    rclone
    rsync

    # --- Fonts & Theming ---
    font-awesome
    noto-fonts
    fira-code
    nerd-fonts.jetbrains-mono
    jetbrains-mono
    victor-mono
    libsForQt5.qtstyleplugin-kvantum
    libsForQt5.qt5ct
    qt6Packages.qt6ct

    # --- Miscellaneous ---
    duf
    evtest
    eza
    grc
    grim
    inotify-tools
    jdk
    less
    man
    mtools
    redshift
    slurp
    speedtest-cli
    starship
    tmux
    toilet
    yad
    libnotify
    steam-run
    kdePackages.kpmcore
    languagetool
    nixfmt-rfc-style

    # --- Unstable Packages ---
    unstable.opencode
    unstable.gemini-cli
    unstable.antigravity
  ];
}
