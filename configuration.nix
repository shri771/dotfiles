# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 4;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 1;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "shri-nix"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Kolkata";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # Enable Bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  # Enable Blueman (this adds the package AND the service)
  services.blueman.enable = true;

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
  console.keyMap = "dvorak-programmer";
  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "dvp";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

## Gonme boxes
virtualisation.libvirtd.enable = true;


## Enable Dcoker
virtualisation.docker.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };
   # Enable all firmware (recommended)
  hardware.enableAllFirmware = true;

  # Allow non-free packages (needed for some firmware)
  nixpkgs.config.allowUnfree = true;

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    # Add any missing dependencies here if the executable still fails to run.
    # For Electron apps, it often needs things like:
    # libglib glibc
  ];

  # Enable fish
  programs.fish.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.shri = {
    isNormalUser = true;
    description = "shri";
    extraGroups = [ "networkmanager" "wheel" "docker" "kvm" ];
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

  ## Enable faltpak
  services.flatpak.enable = true;
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  ## For prevent crashes
  services.earlyoom = {
    enable = true;
    # Start killing processes when free RAM drops below 5%
    freeMemThreshold = 5;
    # Optional: Prefer killing specific heavy processes (regex)
    extraArgs = [ "--prefer" "(^|/)(antigravity|language_server|node)$" ];
  };


 ## Enable Zram
zramSwap = {
    enable = true;
    memoryPercent = 80; 
  };

## Setup TLP 
services.tlp = {
      enable = true;
      settings = {
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      };
  };
  services.power-profiles-daemon.enable = false;

## For openrgb
services.hardware.openrgb.enable = true;
boot.kernelModules = [ "i2c-dev" "i2c-piix4" "kvm-intel" ];

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

  ## for Kero keyboard
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


  # Enable Hyprland and Awesome
  programs.hyprland.enable = true;
  services.xserver.windowManager.awesome.enable = true;


  # Enable Gonme keyring
  # services.gnome.gnome-keyring.enable = true;
  # security.pam.services.sddm.enableGnomeKeyring = true;
  security.pam.services.login.enableGnomeKeyring = true;



  # Enable Expermental features
    nix.settings.experimental-features = [ "nix-command" "flakes" ];


  # Install firefox.
  programs.firefox.enable = true;


## For QT apps
environment.variables = {
    # Force the style to Breeze (safe, standard KDE look)
    QT_STYLE_OVERRIDE = "breeze";
    
    # Tell Qt Quick apps (like Kamoso) to use the desktop style, not Hyprland's
    QT_QUICK_CONTROLS_STYLE = "org.kde.desktop";
    
    # Use the KDE platform theme (since you have Plasma installed)
    # If this causes issues in Hyprland, change "kde" to "qtct"
    QT_QPA_PLATFORMTHEME = "kde";
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
   wget
  neovim
  libnotify

   # pkgs.antigravity
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-curses;  # or pinentry-gtk2, pinentry-qt, pinentry-gnome3
    enableSSHSupport = true;
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?

}
