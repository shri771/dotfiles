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

  # 1. Use KDE platform theme so native KDE apps (Dolphin, etc.) read kdeglobals
  qt = {
    enable = true;
    platformTheme.name = "kde";
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
    kdePackages.breeze # Color schemes + Breeze theme files
  ];

  # 3. Force Qt/KDE apps to use WhiteSur icons AND the BreezeDark color scheme
  #    Full color values are inlined so KDE apps work outside of a Plasma session.
  xdg.configFile."kdeglobals".text = ''
    [General]
    ColorScheme=BreezeDark
    Name=Breeze Dark
    shadeSortColumn=true
    widgetStyle=Breeze

    [Icons]
    Theme=WhiteSur

    [KDE]
    LookAndFeelPackage=org.kde.breezedark.desktop
    widgetStyle=breeze

    [Colors:View]
    BackgroundNormal=35,38,41
    BackgroundAlternate=43,46,50
    DecorationFocus=61,174,233
    DecorationHover=61,174,233
    ForegroundNormal=252,252,252
    ForegroundInactive=161,169,177
    ForegroundActive=61,174,233
    ForegroundLink=29,153,243
    ForegroundVisited=155,89,182
    ForegroundNegative=218,68,83
    ForegroundNeutral=246,116,0
    ForegroundPositive=39,174,96

    [Colors:Window]
    BackgroundNormal=49,54,59
    BackgroundAlternate=77,77,77
    DecorationFocus=61,174,233
    DecorationHover=61,174,233
    ForegroundNormal=252,252,252
    ForegroundInactive=161,169,177
    ForegroundActive=61,174,233
    ForegroundLink=29,153,243
    ForegroundVisited=155,89,182
    ForegroundNegative=218,68,83
    ForegroundNeutral=246,116,0
    ForegroundPositive=39,174,96

    [Colors:Button]
    BackgroundNormal=49,54,59
    BackgroundAlternate=77,77,77
    DecorationFocus=61,174,233
    DecorationHover=61,174,233
    ForegroundNormal=252,252,252
    ForegroundInactive=161,169,177
    ForegroundActive=61,174,233
    ForegroundLink=29,153,243
    ForegroundVisited=155,89,182
    ForegroundNegative=218,68,83
    ForegroundNeutral=246,116,0
    ForegroundPositive=39,174,96

    [Colors:Selection]
    BackgroundNormal=61,174,233
    BackgroundAlternate=29,153,243
    DecorationFocus=61,174,233
    DecorationHover=61,174,233
    ForegroundNormal=252,252,252
    ForegroundInactive=161,169,177
    ForegroundActive=252,252,252
    ForegroundLink=253,188,75
    ForegroundVisited=189,195,199
    ForegroundNegative=176,55,69
    ForegroundNeutral=198,92,0
    ForegroundPositive=23,104,57

    [Colors:Tooltip]
    BackgroundNormal=49,54,59
    BackgroundAlternate=77,77,77
    DecorationFocus=61,174,233
    DecorationHover=61,174,233
    ForegroundNormal=252,252,252
    ForegroundInactive=161,169,177
    ForegroundActive=61,174,233
    ForegroundLink=29,153,243
    ForegroundVisited=155,89,182
    ForegroundNegative=218,68,83
    ForegroundNeutral=246,116,0
    ForegroundPositive=39,174,96

    [Colors:Complementary]
    BackgroundNormal=42,46,50
    BackgroundAlternate=77,77,77
    DecorationFocus=61,174,233
    DecorationHover=61,174,233
    ForegroundNormal=252,252,252
    ForegroundInactive=161,169,177
    ForegroundActive=61,174,233
    ForegroundLink=29,153,243
    ForegroundVisited=155,89,182
    ForegroundNegative=218,68,83
    ForegroundNeutral=246,116,0
    ForegroundPositive=39,174,96

    [Colors:Header]
    BackgroundNormal=42,46,50
    BackgroundAlternate=49,54,59
    DecorationFocus=61,174,233
    DecorationHover=61,174,233
    ForegroundNormal=252,252,252
    ForegroundInactive=161,169,177
    ForegroundActive=61,174,233
    ForegroundLink=29,153,243
    ForegroundVisited=155,89,182
    ForegroundNegative=218,68,83
    ForegroundNeutral=246,116,0
    ForegroundPositive=39,174,96

    [WM]
    activeBackground=49,54,59
    activeForeground=252,252,252
    inactiveBackground=42,46,50
    inactiveForeground=161,169,177
  '';
}
