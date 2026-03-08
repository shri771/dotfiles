# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{ inputs, lib, config, pkgs, ... }: {
  # You can import other home-manager modules here
  imports = [

    # pkg
    ../modules/home-manager/base-pkg.nix
    ../modules/home-manager/extra-pkg.nix

    # Base config
    ../modules/home-manager/base-config.nix
    ../modules/home-manager/theme.nix
    ../modules/home-manager/setup-symlink.nix
    ../modules/home-manager/git-config.nix
  ];

  config = {
    home = {
      stateVersion = "23.11";
      username = "shri";
      homeDirectory = "/home/shri";
    };
  };
}