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
  isoImage.isoName = "shri-nix-${config.system.nixos.release}-live.iso";
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

  # --- Copy dotfiles into each normal user's home directory ---
  system.activationScripts.copyDotfiles =
    let
      normalUsers = builtins.filter (u: config.users.users.${u}.isNormalUser) (
        builtins.attrNames config.users.users
      );
    in
    ''
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
