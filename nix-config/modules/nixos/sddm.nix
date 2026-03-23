{ pkgs, ... }:

let
  # Custom derivation for Ittu SDDM Theme
  ittu-sddm-theme = pkgs.stdenv.mkDerivation {
    pname = "ittu-sddm-theme";
    version = "1.0";

    src = pkgs.fetchFromGitHub {
      owner = "adhec";
      repo = "sddm_themes";
      rev = "master";
      sha256 = "0bk0z9ln3ha0pnc1fb48bvp077zjizlada4fsjb2548vdvydpggb";
    };

    installPhase = ''
      mkdir -p $out/share/sddm/themes/ittu
      if [ -d "ittu" ]; then
        cp -aR ittu/* $out/share/sddm/themes/ittu/
      else
        cp -aR * $out/share/sddm/themes/ittu/
      fi
    '';
  };
in
{
  services.displayManager.sddm = {
    enable = true;
    # If wayland.enable causes issues with older themes, we can toggle it off,
    # but let's try to keep it for performance first.
    wayland.enable = false; 
    theme = "ittu";
    package = pkgs.kdePackages.sddm;
    
    # Add theme and dependencies to SDDM's environment
    extraPackages = [
      ittu-sddm-theme
      pkgs.kdePackages.qt5compat
      pkgs.kdePackages.qtdeclarative
      pkgs.kdePackages.qtsvg
    ];
  };

  environment.systemPackages = [
    ittu-sddm-theme
    pkgs.kdePackages.qt5compat
    pkgs.kdePackages.qtdeclarative
    pkgs.kdePackages.qtsvg
  ];

  # Extra SDDM Tweaks
  services.displayManager.sddm.settings = {
    General = {
      InputMethod = "";
    };
    Theme = {
      CursorTheme = "Bibata-Modern-Classic";
    };
  };

  # Ensure Numlock is on (Works for X11, Wayland depends on compositor)
  services.xserver.displayManager.setupCommands = ''
    ${pkgs.numlockx}/bin/numlockx on
  '';
}
