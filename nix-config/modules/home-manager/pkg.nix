{ config, lib, pkgs, inputs, ... }:

let
  # Initialize the unstable channel exactly as you had it
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
    ffmpeg
    obs-studio
    mpv
    cava
    mpc
    mpd
    ncmpcpp
    cantata

    # --- CLI & Core Utilities ---
    gnumake
    psmisc
    ripgrep # Fixes Telescope error
    jq
    gcc
    htop
    btop
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
    zoxide
    plocate
    powertop
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

    # --- Reading & Documents ---
    foliate
    calibre
    pandoc
    marksman
    glow
    libreoffice-qt

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
    wireshark
    eog
    feh
    sxiv
    flameshot
    shotwell
    loupe
    qalculate-gtk
    krita
    krusader
    nemo
    kdePackages.filelight
    gnome-boxes
    virt-manager
    easyeffects

    # --- Development & Containers ---
    nodejs
    docker
    lazydocker
    minikube
    kubectl
    kubernetes-helm
    gh
    cmake
    meson
    flex
    sqlite
    postgresql
    postman
    direnv
    dysk
    temporal-cli

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
    gpg-tui
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
    cowsay
    duf
    evtest
    eza
    flatpak
    grc
    grim
    inotify-tools
    jdk
    less
    man
    mtools
    nginx
    redshift
    rustc
    slurp
    sox
    speedtest-cli
    starship
    tmux
    toilet
    translate-shell
    typescript
    variety
    yad
    libnotify
    ostree
    steam-run
    kdePackages.kpmcore
    languagetool
    nixfmt-rfc-style # <-- Updated to fix the yellow warning!

    # --- Unstable Packages ---
    unstable.opencode
    unstable.gemini-cli
    unstable.antigravity
  ];
}
