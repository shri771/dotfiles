# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  # You can import other home-manager modules here
  imports = [
    # If you want to use modules your own flake exports (from modules/home-manager):
    # inputs.self.homeManagerModules.example

    # Or modules exported from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModules.default

    # You can also split up your configuration and import pieces of it here:
    # ./nvim.nix
  ];

  # Theme
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
      theme = {
          name = "Breeze-Dark";
          package = pkgs.kdePackages.breeze-gtk;
      };
  };

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      inputs.self.overlays.additions
      inputs.self.overlays.modifications
      inputs.self.overlays.unstable-packages

      # You can also add overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
    };
  };

  # UserNmae
  home = {
    stateVersion = "23.11";
    username = "shri";
    homeDirectory = "/home/shri";
  };


  # Enable home-manager and git
  programs.home-manager.enable = true;
  programs.git.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

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
    psmisc
    ripgrep        # Fixes Telescope error
    nodejs         # For npm-based tools
    polkit
    qrencode
    jq
    gcc
    htop
    foliate
    calibre
    wireshark
    rofi
    bat
    brightnessctl
    opencode
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
    ffmpeg
    libreoffice-qt
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
    temporal-cli

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


  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
}
