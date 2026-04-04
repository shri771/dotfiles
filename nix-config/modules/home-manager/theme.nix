{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
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

  qt = {
    enable = true;
    platformTheme.name = "gtk3"; # mirrors your GTK theme automatically
    style = {
      name = "adwaita-dark";
      package = pkgs.adwaita-qt;
    };
  };

  # Qt6 icon + adwaita support
  home.packages = with pkgs; [
    adwaita-qt # Qt5 dark style
    adwaita-qt6 # Qt6 dark style
    whitesur-icon-theme # same icons as GTK
  ];

  # Force icon theme for Qt apps
  xdg.configFile."kdeglobals".text = ''
    [Icons]
    Theme=WhiteSur
  '';
}
