# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
{
  # You can import other home-manager modules here
  imports = [

    # pkg
    ../modules/pkgs/user-base-pkg.nix
    ../modules/pkgs/user-extra-pkg.nix

    # Base config
    ../modules/home-manager/user-theme.nix
    ../modules/home-manager/user-default.nix
    ../modules/home-manager/symlinks.nix
    ../modules/home-manager/git.nix
    ../modules/home-manager/rclone-gdrive.nix
  ];

  config = {
    home = {
      stateVersion = "26.05";
      username = "shri";
      homeDirectory = "/home/shri";
    };

  };
}
