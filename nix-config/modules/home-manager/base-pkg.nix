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
    system = pkgs.system;
    config.allowUnfree = true;
  };
in
{
  home.packages = with pkgs; [
    # --- 1. Common Logic & Utility Packages (Used in both Hypr/Awesome) ---
    rofi
    yad
    cliphist
    copyq
    playerctl
    imagemagick
    socat
    wallust
    wtype
    ydotool
    jq
    bc
    acpi
    brightnessctl
    pamixer
    pavucontrol
    alsa-utils
    pulseaudio
    libnotify
    inotify-tools
    psmisc
    gnumake
    gcc
    htop
    bat
    fastfetch
    fd
    tree
    wget
    curl
    lsd
    eza
    duf
    ripgrep
    fzf
    rclone
    rsync

    # --- 2. Hyprland / Wayland Stack ---
    hyprland
    hypridle
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
    wl-clipboard
    grim
    slurp
    wf-recorder
    batsignal

    # --- 3. AwesomeWM / X11 Stack ---
    polybar
    picom
    lxappearance
    nitrogen
    arandr
    xdotool
    xclip
    wmctrl
    xorg.xprop
    xdo
    sxhkd
    xorg.xinit
    xss-lock
    numlockx
    scrot
    i3lock-color
    clipnotify
    i3blocks
    eww

    # --- 4. Hardware Specific (ASUS & Laptop) ---
    asusctl
    tlp
    corectrl
    libinput
    bibata-cursors

    # --- 5. Media & Video ---
    vlc
    mpv
    cava
    mpc
    ncmpcpp
    losslesscut-bin
    shotwell
    loupe

    # --- 6. System, Hardware & Networking ---
    polkit
    polkit_gnome
    blueman
    bluez-tools
    networkmanagerapplet
    os-prober
    gparted
    dosfstools
    nvme-cli
    kdePackages.dolphin
    nmap
    hashcat
    john
    encfs
    gnupg
    pinentry-gnome3
    seahorse
    conntrack-tools
    tor
    usbutils
    mtools

    # --- 7. Apps & GUI Tools ---
    qrencode
    qalculate-gtk
    nemo
    kdePackages.filelight
    kdePackages.kpmcore
    alacritty
    kitty
    normcap

    # --- 8. Development & Languages ---
    # Containers & Cloud
    docker
    minikube
    kubectl
    kubernetes-helm
    gh
    # C/C++ & General Dev
    cmake
    meson
    flex
    sqlite
    postgresql
    direnv
    dysk
    # Go Language
    go
    gopls
    (lib.lowPrio gotools)
    golangci-lint
    delve
    sqls
    gofumpt
    # Python
    pipx
    uv
    (pkgs.python3.withPackages (python-pkgs: [
      python-pkgs.numpy
      python-pkgs.pip
    ]))
    # Misc Dev
    nodejs
    jdk
    nixfmt-rfc-style
    languagetool

    # --- 9. Fonts & Theming ---
    font-awesome
    noto-fonts
    fira-code
    nerd-fonts.jetbrains-mono
    jetbrains-mono
    victor-mono
    libsForQt5.qtstyleplugin-kvantum
    libsForQt5.qt5ct
    qt6Packages.qt6ct

    # --- 10. Miscellaneous & Tools ---
    trash-cli
    plocate
    pv
    stress-ng
    sysbench
    zbar
    evtest
    grc
    less
    man
    speedtest-cli
    starship
    tmux
    toilet
    steam-run
    redshift

  ];
}
