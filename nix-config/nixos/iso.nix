{ pkgs, lib, modulesPath, config, primaryUser, ... }:

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

  # --- Embed all build dependencies for offline install ---
  system.includeBuildDependencies = true;

  # --- Copy dotfiles into each normal user's home directory ---
  system.activationScripts.copyDotfiles = let
    normalUsers = builtins.filter
      (u: config.users.users.${u}.isNormalUser)
      (builtins.attrNames config.users.users);
  in ''
    ${builtins.concatStringsSep "\n" (map (u: let
      userHome = config.users.users.${u}.home;
    in ''
      mkdir -p ${userHome}/dotfiles
      cp -rT ${dotfilesSrc} ${userHome}/dotfiles
      chown -R ${u}:users ${userHome}/dotfiles
    '') normalUsers)}
  '';
}
