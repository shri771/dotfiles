{ config, pkgs, ... }:
let
  notion-electron = pkgs.appimageTools.wrapType2 {
    pname = "notion-electron";
    version = "1.9.3";
    src = pkgs.fetchurl {
      url = "https://github.com/anechunaev/notion-electron/releases/download/v1.9.3/Notion_Electron-1.9.3-x86_64.AppImage";
      # Don't forget to replace this with the hash you got from 'nix-prefetch-url'
      sha256 = "0pc9rbzij8x7hb1y3w4rf7kvb5xv7jj98nbj2r7978axzdflz2nh";
    };
  };
in
{

 ## Theme
    gtk = {
        enable = true;

        font = {
            name = "Noto Sans";
            size = 10;
        };

        iconTheme = {
            package = pkgs.whitesur-icon-theme;
            name = "WhiteSur";
        };

# Add this block to set the theme
        theme = {
            name = "Breeze-Dark";
            package = pkgs.kdePackages.breeze-gtk;
        };
    };

  home.stateVersion = "23.11";
  home.username = "shri";
  home.homeDirectory = "/home/shri";
  home.enableNixpkgsReleaseCheck = false;

  services.gnome-keyring = {
      enable = true;
      components = [ "secrets" "ssh" "pkcs11" ];
  };

  home.sessionPath = [
    "$HOME/go/bin"
  ];
# Allow proprietary/unfree packages globally
  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
  notion-electron
  psmisc
      ripgrep        # Fixes Telescope error
    nodejs         # For npm-based tools
    polkit
    qrencode
    jq
    gcc
    htop
    rofi
    bat
    brightnessctl
    cantata
    acpi
    alacritty
    arandr
    bc
    blueman
    bluez-tools
    btop
    carapace
    cava
    cliphist
    cmake
    corectrl
    cowsay
    docker
    dosfstools
    duf
    encfs
    eog
    evtest
    eza
    fastfetch
    fd
    feh
    kdePackages.filelight
    flameshot
    flatpak
    flex
    foliate
    gh
    gparted
    grc
    grim
    hashcat
    hypridle
    hyprland
    hyprlock
    hyprpolkitagent
    i3blocks
    inotify-tools
    jdk
    john
    # plasma5Packages.kdeconnect-kde
    kitty
    krita
    krusader
    libsForQt5.qtstyleplugin-kvantum
    lazydocker
    less
    loupe
    seahorse
    lsd
    lsof
    lxappearance
    man
    meson
    mpc
    mpd
    mpv
    mtools
    ncmpcpp
    nemo
    networkmanagerapplet
    nginx
    nitrogen
    nmap
    numlockx
    nvme-cli
    nwg-displays
    nwg-look
    obs-studio
    os-prober

    ## Founts
    font-awesome
    noto-fonts
    fira-code
    jetbrains-mono
    nerd-fonts.jetbrains-mono
    pamixer
    pandoc
    # parcellite
    uv
    pavucontrol
    wl-clipboard
    picom
    playerctl
    plocate
    polkit_gnome
    polybar
    postgresql
    powertop
    pv
    pyprland
    qalculate-gtk
    libsForQt5.qt5ct
qt6Packages.qt6ct
    rclone
    redshift
    rsync
    rustc
    seahorse
    shotwell
    slurp
    sox
    speedtest-cli
    starship
    stress-ng
    swappy
    swaybg
    swayimg
    swaynotificationcenter
    swww
    sxhkd
    sxiv
    sysbench
    tlp
    tmux
    toilet
    tor
    translate-shell
    trash-cli
    tree
    fira-code
    jetbrains-mono
    victor-mono
    typescript
    variety
    virt-manager
    virtualbox
    waybar
    wget
    wlogout
    xclip
    xdg-desktop-portal-hyprland
    xdotool
    xorg.xinit
    xss-lock
    yad
    ydotool
    zbar
    zoxide
    gnupg
    gpg-tui
    pipx
    python3
    pinentry-gnome3
    libnotify
    gemini-cli
    kanshi
    ddcutil
    libinput
    usbutils
    ostree
    gnome-boxes
    kdePackages.kamoso
    easyeffects
    treemd
    antigravity
    curl
    direnv
    dysk
    minikube
    kubectl
    sqlite
    steam-run
    kdePackages.kpmcore
    curl
    gh
    conntrack-tools
     kubernetes-helm
        # nodePackages.live-server

    # antigravity

    # LSP
    go
    gopls          # The official Go Language Server (LSP)
    (lib.lowPrio gotools)        # Contains 'goimports', etc.
    golangci-lint  # Fast linter
    delve          # Debugger (dlv)
    sqls
    gofumpt
  ];

  programs.home-manager.enable = true;
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;

    # extraPackages = with pkgs; [
    #   # Additional LSP servers and tools
    #   nodePackages.typescript-language-server
    #   nodePackages.vscode-langservers-extracted
    # ];
  };
}
