# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{ inputs, lib, config, pkgs, ... }: {
  # You can import other home-manager modules here
  imports = [
    # pkg
    ../modules/home-manager/pkgs/base.nix
    # ../modules/home-manager/pkgs/extra.nix
    # Base config
    ../modules/home-manager/core.nix
    ../modules/home-manager/theme.nix
    ../modules/home-manager/links.nix
    ../modules/home-manager/git.nix
  ];

  # UserNmae
  home = {
    stateVersion = "23.11";
    username = "tst";
    homeDirectory = "/home/tst";
  };}
