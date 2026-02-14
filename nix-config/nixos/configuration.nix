# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  # You can import other NixOS modules here
  imports = [
    # If you want to use modules your own flake exports (from modules/nixos):
    # inputs.self.nixosModules.example

    # Or modules from other flakes (such as nixos-hardware):
    # inputs.hardware.nixosModules.common-cpu-amd
    # inputs.hardware.nixosModules.common-ssd

    # You can also split up your configuration and import pieces of it here:
    # ./users.nix

    # Import your generated (nixos-generate-config) hardware configuration
    ./hardware-configuration.nix
  ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      inputs.self.overlays.additions
      inputs.self.overlays.modifications
      inputs.self.overlays.unstable-packages

      # inputs.neovim-nightly-overlay.overlays.default

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

  nix = let
    flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
  in {
    settings = {
      # Enable flakes and new 'nix' command
      experimental-features = "nix-command flakes";
      # Disable global registry
      flake-registry = "";
      # Workaround for https://github.com/NixOS/nix/issues/9574
      nix-path = config.nix.nixPath;
    };

    # Disable channels
    channel.enable = false;
    # Opinionated: make flake registry and nix path match flake inputs
    registry = lib.mapAttrs (_: flake: {inherit flake;}) flakeInputs;
    nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;
  };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 4;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 1;

  # Use latest version
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Netowrk
  networking.hostName = "shri-nix";
  networking.networkmanager.enable = true;

    # Set your time zone.
  time.timeZone = "Asia/Kolkata";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # Bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  # Locale
    i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_IN";
    LC_IDENTIFICATION = "en_IN";
    LC_MEASUREMENT = "en_IN";
    LC_MONETARY = "en_IN";
    LC_NAME = "en_IN";
    LC_NUMERIC = "en_IN";
    LC_PAPER = "en_IN";
    LC_TELEPHONE = "en_IN";
    LC_TIME = "en_IN";
  };

  # Keyboard
  console.keyMap = "dvorak-programmer";
   # For x11
  services.xserver.xkb = {
      layout = "us";
      variant = "dvp";
  };

  # x11
  services.xserver.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # Firmware
  hardware.enableAllFirmware = true;

  # Touchpad
  services.libinput.enable = true;
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    # libglib glibc
  ];

  # User
  users.users.shri = {
      isNormalUser = true;
      description = "Honor Desktop";
      extraGroups = [ "networkmanager" "wheel" "docker" "kvm""wireshark" ];
      initialPassword = "as";
      openssh.authorizedKeys.keys = [
          "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDPchxx8m1n/DJ2qGd5egSbEET7RvhKhG5p1jBhrb7o4GYYqmQLIRS9NEA3DybcNl5wKcbx1ROveHN7RhX29f3Me2DQRtcsmFfcEaOlULgeMY03dqJ596u5DvMw3dwclgGnCF2aybiDh2b+51DJeNevvIl3RzKbnnIpWhfX7hnK2Z0llk1A80v6+jV2PJJcUTGOhoetsTNuceUDs2b5HSs/m55htq1txu7h9imapMcEruVskg5t2glVKWvBUFRk+p0DQRU8iasD/exkmSQHCCicvmCYOjQqPPAOB61CSfPbIJvc4VZDKCRRgty5RkROVpAAhxrRU+MzVxb153ww+h8L shrikantshingare77@gmail.com"
      ];

      shell = pkgs.fish;
      packages = with pkgs; [
          git
              pkgs.gnome-keyring
              pkgs.seahorse
              libsecret       # Required by some apps
              neovim
              curl
              fish
              starship
              brave
              vivaldi
              jq
              zoxide
              eza
              kitty
              carapace
              fzf
              home-manager
              unzip
              tmux
              evremap
              awesome
              hyprland
              polkit
              trash-cli
              kdePackages.kate
              noto-fonts
              noto-fonts-color-emoji
              openrgb-with-all-plugins

              ];
  };

  # Enable Zram
  zramSwap = {
      enable = true;
      memoryPercent = 80;
  };

  # Setup TLP
  services.tlp = {
      enable = true;
      settings = {
          CPU_SCALING_GOVERNOR_ON_AC = "performance";
          CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      };
  };
  services.power-profiles-daemon.enable = false;

  # Enable Hyprland and Awesome
  programs.hyprland.enable = true;
  services.xserver.windowManager.awesome.enable = true;


  # Gonme keyring
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.login.enableGnomeKeyring = true;

  # Fish
  programs.fish.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # WireShrak
  programs.wireshark.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Gonme boxes
  virtualisation.libvirtd.enable = true;

  # Enable Dcoker
  virtualisation.docker.enable = true;

  # Enable faltpak
  services.flatpak.enable = true;
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  ## For prevent crashes of antigravity
  services.earlyoom = {
    enable = true;
    # Start killing processes when free RAM drops below 5%
    freeMemThreshold = 5;
    # Optional: Prefer killing specific heavy processes (regex)
    extraArgs = [ "--prefer" "(^|/)(antigravity|language_server|node)$" ];
  };

  # Install firefox.
  programs.firefox.enable = true;

  ### Systemd Services ###

  # Main keyboard
  systemd.services.evremap-main = {
    description = "Evremap Main";

    # Start after the multi-user target is reached
    after = [ "multi-user.target" ];
    wantedBy = [ "multi-user.target" ];

    # Service configuration
    serviceConfig = {
      # In NixOS, we don't use /usr/bin. We reference the package directly.
      ExecStart = "${pkgs.evremap}/bin/evremap remap /home/shri/.config/evremap/evremap.conf";
      Restart = "always";

      # Evremap usually requires root to grab input devices (/dev/input)
      # even if it is reading a user's config file.
      User = "root";
    };
  };

  # For QT apps
  environment.variables = {
    # Force the style to Breeze (safe, standard KDE look)
    QT_STYLE_OVERRIDE = "breeze";

    # Tell Qt Quick apps (like Kamoso) to use the desktop style, not Hyprland's
    QT_QUICK_CONTROLS_STYLE = "org.kde.desktop";

    # Use the KDE platform theme (since you have Plasma installed)
    # If this causes issues in Hyprland, change "kde" to "qtct"
    QT_QPA_PLATFORMTHEME = "kde";
  };

  environment.systemPackages = with pkgs; [
   wget
   neovim
   libnotify
  ];

  # GPG
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-curses;  # or pinentry-gtk2, pinentry-qt, pinentry-gnome3
    enableSSHSupport = true;
  };

  # SSH
  services.openssh.enable = true;
  services.openssh = {
  enable = true;
  settings = {
    PermitRootLogin = "no";
    PasswordAuthentication = true;
    KbdInteractiveAuthentication = true;
  };
  ports = [ 22 ];
  };

  # Kero keyboard
    systemd.services.evremap-kreo = {
    description = "Evremap Kreo";

    # Start after the multi-user target is reached
    after = [ "multi-user.target" ];
    wantedBy = [ "multi-user.target" ];

    # Service configuration
    serviceConfig = {
      # In NixOS, we don't use /usr/bin. We reference the package directly.
      ExecStart = "${pkgs.evremap}/bin/evremap remap /home/shri/dotfiles/evremap/evremap-kero.conf";
      Restart = "always";

      # Evremap usually requires root to grab input devices (/dev/input)
      # even if it is reading a user's config file.
      User = "root";
    };
  };




  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "25.05";
}
