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
    lsd
    duf
    ripgrep
    rclone
    rsync

    # --- 2. Hyprland / Wayland Stack ---
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
    unstable.nodejs
    jdk
    nixfmt-rfc-style
    languagetool

    # --- 9. Fonts & Theming ---
    font-awesome
    fira-code
    nerd-fonts.jetbrains-mono
    jetbrains-mono
    victor-mono
    libsForQt5.qtstyleplugin-kvantum
    libsForQt5.qt5ct
    qt6Packages.qt6ct

    # --- 10. Miscellaneous & Tools ---
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
    toilet
    steam-run
    redshift

    # --- 11. Unstable Packages ---
    unstable.opencode
    unstable.gemini-cli
    unstable.antigravity
  ];
}
