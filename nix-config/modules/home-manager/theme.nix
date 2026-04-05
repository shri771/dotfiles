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

  # 1. Set the style to Breeze (which supports QML properly)
  qt = {
    enable = true;
    platformTheme.name = "gtk3";
    style = {
      name = "breeze";
      package = pkgs.kdePackages.breeze;
    };
  };

  # 2. Add the necessary KDE/Qt QML dependencies
  home.packages = with pkgs; [
    whitesur-icon-theme
    kdePackages.qqc2-desktop-style # Needed for QML apps like EasyEffects
    kdePackages.kirigami # Needed for QML apps like EasyEffects
  ];

  # 3. Force Qt apps to use WhiteSur icons AND the dark color scheme
  xdg.configFile."kdeglobals".text = ''
    [Icons]
    Theme=WhiteSur

    [General]
    ColorScheme=BreezeDark
  '';
}
