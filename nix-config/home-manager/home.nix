# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{ inputs, lib, config, pkgs, ... }: {
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
  programs.git.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  services.gnome-keyring = {
    enable = true;
    components = [ "secrets" "ssh" "pkcs11" ];
  };

  home.sessionPath = [ "$HOME/go/bin" ];

  # This pulls in the bleeding-edge packages for the tools that aren't in stable yet
  home.packages = let
    unstable = import inputs.nixpkgs-unstable {
      system = pkgs.system;
      config.allowUnfree = true;
    };
  in with pkgs; [
    wf-recorder
    losslesscut-bin
    gnumake
    psmisc
    ripgrep # Fixes Telescope error
    nodejs # For npm-based tools
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
    unstable.opencode # <-- Pulling from unstable
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
    nerd-fonts.jetbrains-mono
    pamixer
    pandoc
    marksman
    glow
    languagetool
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
    jetbrains-mono
    victor-mono
    typescript
    variety
    virt-manager
    waybar
    postman
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
    unstable.gemini-cli # <-- Pulling from unstable
    kanshi
    ddcutil
    libinput
    usbutils
    ostree
    gnome-boxes
    # kdePackages.kamoso
    easyeffects
    # treemd
    unstable.antigravity # <-- Pulling from unstable
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

    # LSP
    go
    gopls # The official Go Language Server (LSP)
    (lib.lowPrio gotools) # Contains 'goimports', etc.
    golangci-lint # Fast linter
    delve # Debugger (dlv)
    sqls
    gofumpt
    batsignal
    nixfmt

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

  # Low battery waring
  services.batsignal = {
    enable = true;
    extraArgs = [ "-w" "20" "-c" "10" "-d" "5" ];
  };

  # Git Config
  programs.git = {
    # enable = true;
    userName = "Shrikant Shingare";
    userEmail = "shrikantshingare77@gmail.com";

    # This single line handles all your filter.lfs.* settings automatically!
    lfs.enable = true;

    signing = {
      key = "shrikantshingare77@gmail.com";
      signByDefault = true;
    };

    extraConfig = {
      init = { defaultBranch = "master"; };
      pull = { rebase = true; };

      # Git diff tool settings
      diff = { tool = "nvim"; };
      difftool.nvim = { cmd = "nvim -d"; };

      # Credentials
      credential = { helper = "libsecret"; };

      # UI Colors
      color = {
        ui = "auto";
        diff = "auto";
        status = "auto";
        branch = "auto";
        log = "auto";
      };

      "color \"status\"" = {
        added = "#50fa7b";
        changed = "#f1fa8c";
        untracked = "#ff5555";
        branch = "#8be9fd";
      };

      "color \"diff\"" = {
        meta = "#bd93f9";
        frag = "#ff79c6";
        old = "#ff5555 bold";
        new = "#50fa7b bold";
        whitespace = "#ff5555 reverse";
      };

      "color \"branch\"" = {
        local = "#8be9fd";
        remote = "#ff79c6";
      };
    };
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
}
