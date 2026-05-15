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
in
{
  home.packages = with pkgs; [
    # --- 1. Common Logic & Utility Packages (Used in both Hypr/Awesome) ---
    openssl
    p7zip
    zip
    clamav
    bubblewrap
    binwalk
    binutils
    hexyl
    yara-x
    file
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
    # rquickshare

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
    hyprland-qt-support

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

    ## Dolphin
    kdePackages.dolphin
    kdePackages.solid # Hardware/USB detection
    kdePackages.kio-extras # Core KIO protocols + basic previews
    kdePackages.kdegraphics-thumbnailers # Image thumbnails
    kdePackages.ffmpegthumbs # Video thumbnails
    kdePackages.kimageformats # Extra image formats
    kdePackages.dolphin-plugins # Git, checksum plugins
    kdePackages.ark # Archive support
    kdePackages.konsole
    kdePackages.purpose
    # Add these for phone/MTP support
    libmtp # Core MTP protocol library
    mtpfs # FUSE MTP filesystem
    jmtpfs # Better MTP support
    gvfs # Virtual filesystem (handles MTP mounting)

    android-tools

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
    pkgs.go-task
    pkgs.bun
    kubectl
    kubernetes-helm
    gh
    lsof
    # C/C++ & General Dev
    unstable.kind
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
    mysql84
    gofumpt
    # Python
    pipx
    uv
    (pkgs.python3.withPackages (python-pkgs: [
      python-pkgs.numpy
      python-pkgs.pip
    ]))
    # OpenAPI
    oapi-codegen
    swagger-cli
    go-swagger
    openapi-generator-cli
    # Misc Dev
    unstable.nodejs
    jdk
    nil
    nixfmt-rfc-style
    languagetool
    unstable.codex
    pkgs.telegram-desktop

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
    cryptsetup
    yt-dlp
    krusader
    stdenv
    hdparm
    borgbackup
    nvme-cli
    pass

    # --- 11. Unstable Packages ---
    unstable.opencode
    unstable.gemini-cli
    unstable.antigravity
    unstable.claude-code
  ];
}
