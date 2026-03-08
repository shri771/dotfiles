{ config, lib, pkgs, inputs, ... }:

{
  # Theme
  gtk = {
    enable = true;

    font = {
      name = "Noto Sans";
      size = 10;
    };

    iconTheme = {
      package = pkgs.whitesur-icon-theme;
      name = "WhiteSur";
    };
    theme = {
      name = "Breeze-Dark";
      package = pkgs.kdePackages.breeze-gtk;
    };
  };
}