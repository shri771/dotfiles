{
  pkgs,
  lib,
  modulesPath,
  config,
  primaryUser,
  ...
}:

let
  # Path to the dotfiles repo (one level above nix-config)
  dotfilesSrc = ../../.;
in
{
  imports = [
    # Minimal live ISO base — no Plasma, no Calamares
    # Your configuration.nix provides SDDM + Hyprland
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
  ];

  nixpkgs.hostPlatform = lib.mkForce "x86_64-linux";

  # --- Override boot/filesystem settings that conflict with ISO ---
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.efi.canTouchEfiVariables = lib.mkForce false;
  boot.loader.timeout = lib.mkForce 10;

  # --- ISO naming ---
  image.fileName = "shri-nix-${config.system.nixos.release}-live.iso";
  isoImage.volumeID = "SHRI_NIX_LIVE";

  # --- Faster SquashFS compression (huge build-time win over default xz) ---
  isoImage.squashfsCompression = "gzip -Xcompression-level 1";

  # --- Embed runtime closure (pre-built binaries) into ISO ---
  # Only bundles what's needed to RUN, not to compile
  isoImage.storeContents = [
    config.system.build.toplevel
  ];

  # --- Broader filesystem support for rescue/installer use ---
  boot.supportedFilesystems = lib.mkForce [ "btrfs" "ext4" "vfat" "xfs" "ntfs" "cifs" ];

  # --- Live hostname (avoid confusion with installed system) ---
  networking.hostName = lib.mkForce "shri-nix-live";

  # --- Passwordless sudo for live use ---
  security.sudo.wheelNeedsPassword = lib.mkForce false;


  # --- Live-only packages ---
  environment.systemPackages = with pkgs; [
    disko    # auto-partitioning (community gold standard)
    gparted  # GUI partition editor
    wget
  ];

  # --- Disable hardware-specific services that will crash on other machines ---
  systemd.services.evremap-main.enable = lib.mkForce false;
  systemd.services.evremap-kreo.enable = lib.mkForce false;

  # --- Prepare writable home directories with XDG structure ---
  # Creates standard XDG dirs + app-specific data dirs needed by:
  # fish, zoxide, gnupg, cliphist, mpd, go, starship, direnv, gtk
  system.activationScripts.prepareUserHomes =
    let
      normalUsers = builtins.filter (u: config.users.users.${u}.isNormalUser) (
        builtins.attrNames config.users.users
      );
    in
    lib.stringAfter [ "users" "groups" ] ''
      ${builtins.concatStringsSep "\n" (
        map (
          u:
          let
            userHome = config.users.users.${u}.home;
          in
          ''
            echo "Preparing home for ${u}..."

            # --- Standard XDG directories ---
            mkdir -p ${userHome}/.config
            mkdir -p ${userHome}/.local/share
            mkdir -p ${userHome}/.local/state
            mkdir -p ${userHome}/.cache

            # --- App-specific data directories ---
            # Fish shell (history, completions, functions)
            mkdir -p ${userHome}/.local/share/fish
            # Zoxide (database)
            mkdir -p ${userHome}/.local/share/zoxide
            # GnuPG (keys and config)
            mkdir -p ${userHome}/.gnupg
            chmod 700 ${userHome}/.gnupg
            # Cliphist (clipboard history)
            mkdir -p ${userHome}/.cache/cliphist
            # MPD (music player daemon)
            mkdir -p ${userHome}/.local/share/mpd
            mkdir -p ${userHome}/.config/mpd
            # Go (GOPATH)
            mkdir -p ${userHome}/go/bin
            # Direnv (allow files)
            mkdir -p ${userHome}/.local/share/direnv
            # GTK theming
            mkdir -p ${userHome}/.config/gtk-3.0
            mkdir -p ${userHome}/.config/gtk-4.0

            chown -R ${u}:users ${userHome}
          ''
        ) normalUsers
      )}
    '';

  # --- Copy dotfiles into each normal user's home directory ---
  system.activationScripts.copyDotfiles =
    let
      normalUsers = builtins.filter (u: config.users.users.${u}.isNormalUser) (
        builtins.attrNames config.users.users
      );
    in
    lib.stringAfter [ "prepareUserHomes" ] ''
      ${builtins.concatStringsSep "\n" (
        map (
          u:
          let
            userHome = config.users.users.${u}.home;
          in
          ''
            if [ ! -d "${userHome}/dotfiles" ]; then
              mkdir -p ${userHome}/dotfiles
              cp -rT ${dotfilesSrc} ${userHome}/dotfiles
              chown -R ${u}:users ${userHome}/dotfiles
              echo "Dotfiles copied for ${u}"
            else
              echo "Dotfiles already exist for ${u}, skipping..."
            fi
          ''
        ) normalUsers
      )}
    '';
}
