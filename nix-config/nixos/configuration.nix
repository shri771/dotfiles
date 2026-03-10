# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
{
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

    # Packages
    ../modules/nixos/user-packages.nix

    # Users
    ../modules/nixos/users/shri.nix
    ../modules/nixos/users/tst.nix

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

  nix =
    let
      flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
    in
    {
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
      registry = lib.mapAttrs (_: flake: { inherit flake; }) flakeInputs;
      nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;
    };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 4;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 1;

  # Use latest version
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Load kernel Mdoules
  boot.kernelModules = [ "i2c-dev" ];

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

  # Disable legacy command-not-found
  programs.command-not-found.enable = false;

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = false;

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
    extraArgs = [
      "--prefer"
      "(^|/)(antigravity|language_server|node)$"
    ];
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
    QT_STYLE_OVERRIDE = "breeze";
    QT_QUICK_CONTROLS_STYLE = "org.kde.desktop";
    QT_QPA_PLATFORMTHEME = "kde";
  };

  # System pkgs
  environment.systemPackages = with pkgs; [
    ddcutil # # For monitor brigthness control
    nix-index
    # ciscoPacketTracer8
  ];

  # GPG
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-gnome3; # or pinentry-gtk2, pinentry-qt, pinentry-gnome3
    enableSSHSupport = true;
  };

  # SSH
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = true;
      KbdInteractiveAuthentication = true;
    };
    ports = [ 22 ];
  };

  # For ddcutil
  hardware.i2c.enable = true;

  # Nfs Server
  services.nfs.server.enable = false;

  # Specific range for GNOME Boxes NAT
  services.nfs.server.exports = ''
    /home/shri/downloads 10.0.2.0/24(rw,nohide,insecure,no_subtree_check,async,no_root_squash)
  '';

  # Termbox
  environment.enableAllTerminfo = true;

  # Open the necessary Firewall ports
  # NFS needs 2049, but often mountd and statd need ports too
  # networking.firewall.allowedTCPPorts = [ 2049 ];
  # networking.firewall.allowedUDPPorts = [ 2049 ];

  # Kero keyboard
  systemd.services.evremap-kreo = {
    description = "Evremap Kreo";

    # Start after the multi-user target is reached
    after = [ "multi-user.target" ];
    wantedBy = [ "multi-user.target" ];

    # Service configuration
    serviceConfig = {
      ExecStart = "${pkgs.evremap}/bin/evremap remap /home/shri/dotfiles/evremap/evremap-kero.conf";
      Restart = "always";

      User = "root";
    };
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "25.05";
}
