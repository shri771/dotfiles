# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
{
  inputs,
  lib,
  config,
  pkgs,
  primaryUser,
  ...
}:
let
  home = config.users.users.${primaryUser}.home;
in
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

    # NOTE: hardware-configuration.nix is imported from flake.nix (not here)
    # so the ISO build doesn't inherit machine-specific disk mounts.

    # Packages
    ../modules/pkgs/system-pkg.nix
    ../modules/nixos/gnome.nix
    ../modules/nixos/faillock.nix
    # Users
    ../modules/nixos/users/shri.nix
    ../modules/nixos/users/tst.nix

    # Docker-Container
    ../modules/Docker-Container/vaultwarden.nix
    # ../modules/nixos/Docker-Container/linkwarden.nix

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
      android_sdk.accept_license = true;
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

  # Disable Plymouth splash screen during shutdown and reboot
  systemd.services."plymouth-poweroff".enable = false;
  systemd.services."plymouth-reboot".enable = false;
  systemd.services."plymouth-halt".enable = false;
  systemd.services."plymouth-kexec".enable = false;

  # Boot
  boot = {
    # THE ONE REQUIRED ADDITION: Forces systemd to handle the LUKS prompt graphically
    initrd.systemd.enable = true;

    # Bootloader configuration
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 4;
      };

      efi.canTouchEfiVariables = true;
      timeout = 1;
    };

    # Use the latest Linux kernel package set
    kernelPackages = pkgs.linuxPackages_latest;
    extraModulePackages = with config.boot.kernelPackages; [
      v4l2loopback
    ];
    extraModprobeConfig = ''
      options v4l2loopback exclusive_caps=1 devices=1 card_label="Iriun Webcam,Iriun Webcam #2,Iriun Webcam #3,Iriun Webcam #4"
    '';

    # --- PLYMOUTH & GUI BOOT SETTINGS ---

    # Enable Plymouth for the graphical LUKS prompt
    plymouth = {
      enable = true;
      theme = "spinner";
    };

    # Early KMS specifically for INTEL GPUs (loads before LUKS prompt)
    initrd.kernelModules = [
      "i915"
      "dm-mod"
    ];

    # Silence the scrolling text for a clean visual boot
    consoleLogLevel = 0;

    # --- END PLYMOUTH SETTINGS ---

    # Combined Kernel parameters (Your autosuspend + Quiet Boot params)
    kernelParams = [
      "usbcore.autosuspend=-1"
    ];

    # Kernel modules that should be loaded during boot
    kernelModules = [
      "i2c-dev"
      "v4l2loopback"
      "snd-aloop"
    ];
  };

  # Hyperledeger Fabric
  environment.variables = {
    # only set this if you need Fabric config files later
    # FABRIC_CFG_PATH = "/home/shri/Workspace/fabric/fabric/fabric-samples/config";
  };

  environment.sessionVariables = {
    PATH = [
      "/home/shri/Workspace/fabric/fabric/fabric-samples/bin"
    ];
  };

  # Network
  networking.hostName = "shri-nix";
  networking.networkmanager.enable = true;

  # Time-Zone
  time.timeZone = "Asia/Kolkata";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # Bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Experimental = true;
        FastConnectable = true;
      };
    };
  };
  services.blueman.enable = true;

  # Power Management
  powerManagement.resumeCommands = ''
    ${pkgs.systemd}/bin/systemctl restart bluetooth
  '';
  # ${pkgs.systemd}/bin/systemctl restart tailscaled

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
  # services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # Passwordless sudo for borg backup (tmux session has no TTY for password input)
  security.sudo.extraRules = [
    {
      users = [ "${primaryUser}" ];
      commands = [
        {
          command = "/run/wrappers/bin/borg *";
          options = [
            "NOPASSWD"
            "SETENV"
          ];
        }
        {
          command = "/home/${primaryUser}/.nix-profile/bin/borg *";
          options = [
            "NOPASSWD"
            "SETENV"
          ];
        }
        {
          command = "/run/current-system/sw/bin/borg *";
          options = [
            "NOPASSWD"
            "SETENV"
          ];
        }
      ];
    }
  ];

  ## For foliate

  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      avahi # libavahi-client.so.3, libavahi-common.so.3
      alsa-lib # libasound.so.2
      libdrm # libdrm.so.2
      qt5.qtbase # libQt5Widgets, libQt5Gui, libQt5Network, libQt5Core
      stdenv.cc.cc # libstdc++.so.6
      qt5.qtwayland
      libusb1
      libusbmuxd
      libGL
      udev
      v4l-utils
      libpulseaudio
    ];
  };

  # Firmware
  hardware.enableAllFirmware = true;

  # Touchpad
  services.libinput.enable = true;
  # programs.nix-ld.libraries = with pkgs; [
  #   # libglib glibc
  # ];

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
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      START_CHARGE_THRESH_BAT0 = 75;
      STOP_CHARGE_THRESH_BAT0 = 81;
    };
  };
  services.power-profiles-daemon.enable = false;

  # Enable Hyprland and Awesome
  programs.hyprland = {
    enable = true;
    withUWSM = true;
  };
  services.xserver.windowManager.awesome.enable = true;

  services.displayManager.defaultSession = "hyprland-uwsm";

  # XDG Desktop Menu (needed for KDE apps like Dolphin to discover installed applications)
  xdg.menus.enable = true;
  environment.etc."xdg/menus/applications.menu".source =
    "${pkgs.kdePackages.plasma-workspace}/etc/xdg/menus/plasma-applications.menu";

  # XDG Desktop Portal (needed for file dialogs, screen sharing, etc.)
  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-hyprland
      pkgs.kdePackages.xdg-desktop-portal-kde
      pkgs.xdg-desktop-portal-termfilechooser
    ];
    config = {
      hyprland = {
        default = [
          "hyprland"
          "kde"
        ];
        # Route file open/save dialogs (browsers, GTK/Qt apps) through ranger
        "org.freedesktop.impl.portal.FileChooser" = [ "termfilechooser" ];
      };
    };
  };

  # Gonme keyring
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.login.enableGnomeKeyring = true;
  services.dbus.packages = [ pkgs.gcr ];

  # Fish
  programs.fish.enable = true;

  # Disable legacy command-not-found
  programs.command-not-found.enable = false;

  # Enable the KDE Plasma Desktop Environment.
  services.desktopManager.plasma6.enable = false;

  # WireShrak
  programs.wireshark.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Gonme boxes
  virtualisation.libvirtd.enable = true;

  # Dcoker
  virtualisation.docker = {
    enable = true;
    daemon.settings = {
      insecure-registries = [ "localhost:8080" ];
    };
  };

  # Enable faltpak
  services.flatpak.enable = true;
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  # TailScale
  # services.tailscale.enable = true;

  # # Install firefox.
  # programs.firefox.enable = true;

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
      ExecStart = "${pkgs.evremap}/bin/evremap remap ${home}/dotfiles/evremap/evremap.conf";
      Restart = "always";

      # Evremap usually requires root to grab input devices (/dev/input)
      # even if it is reading a user's config file.
      User = "root";
    };
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

  # MySQL
  services.mysql = {
    enable = false;
    package = pkgs.mariadb;
  };

  ## If running in VM
  # services.qemuGuest.enable = true;
  # services.spice-vdagentd.enable = true;

  # For the sandisk borg backup
  services.udisks2.enable = true;
  services.udev.extraRules = ''
    # Make all USB block devices non-system and visible to udisks
    SUBSYSTEMS=="usb", SUBSYSTEM=="block", ENV{UDISKS_SYSTEM}="0"

    # SanDisk 3.2Gen1 (0781:55a9) — trigger borg home backup on plug-in
    ACTION=="add", SUBSYSTEM=="block", SUBSYSTEMS=="usb", \
      ENV{ID_FS_UUID}=="beda374d-ea22-4a53-a7e2-a685f598c3a1", \
      TAG+="systemd", ENV{SYSTEMD_WANTS}="home-backup.service"
  '';

  # Systemd service triggered by udev when backup drive is plugged in
  systemd.services.home-backup = {
    description = "Home Borg Backup Trigger";
    path = with pkgs; [
      bash
      coreutils
      util-linux
      gnupg
      pass
      tmux
      borgbackup
    ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "/run/current-system/sw/bin/bash ${home}/dotfiles/scripts/HomeBackup.sh --udev";
    };
  };
  services.gvfs.enable = true; # For mtp

  # Docker-Container
  services.my-vaultwarden.enable = true;
  # services.my-linkwarden.enable = true;

  # KDE
  programs.kdeconnect.enable = true;

  # Firewall
  networking.firewall = rec {
    # Trust Docker bridges so containers on bridge networks can talk through the host firewall.
    trustedInterfaces = [ "docker0" ];
    extraCommands = ''
      iptables -I nixos-fw -i br-+ -j nixos-fw-accept
    '';
    extraStopCommands = ''
      iptables -D nixos-fw -i br-+ -j nixos-fw-accept 2>/dev/null || true
    '';

    allowedTCPPortRanges = [
      {
        # For kde connect
        from = 1714;
        to = 1764;
      }
    ];

    ## For Pi-hole
    allowedTCPPorts = [
      53
      8881
      884
      8096 # Jellyfin (web UI)
    ];
    allowedUDPPorts = [
      53
      7359 # Jellyfin (client auto-discovery)
    ];
    allowedUDPPortRanges = allowedTCPPortRanges;
  };

  ## For Pi-hole (disbale conflicting ports(docker proxy))
  services.resolved.enable = false;

  services.avahi = {
    enable = true;
    nssmdns4 = true; # IPv4 mDNS
    openFirewall = true;
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "25.11";
}
