{ pkgs, lib, ... }:

let
  # Custom derivation for Ittu SDDM Theme
  ittu-sddm-theme = pkgs.stdenv.mkDerivation {
    pname = "ittu-sddm-theme";
    version = "1.0";

    src = pkgs.fetchFromGitLab {
      domain = "git.opendesktop.org";
      owner = "adhe";
      repo = "ittusddm";
      rev = "master";
      sha256 = "sha256-pPBjGgJZGYecoPxPkpwyT3v7riZDV7iotXoFzMCRNdA=";
    };

    installPhase = ''
      mkdir -p $out/share/sddm/themes/ittu
      cp -aR ./* $out/share/sddm/themes/ittu/
    '';
  };
in
{
  services.displayManager.sddm = {
    enable = true;
    # If wayland.enable causes issues with older themes, we can toggle it off.
    wayland.enable = false; 
    theme = "ittu";
    package = pkgs.kdePackages.sddm;
    
    # Add theme and dependencies to SDDM's environment
    # Most older SDDM themes (like Ittu) require Qt 5 libraries to function correctly,
    # even when running under SDDM 6 (Qt 6).
    extraPackages = [
      ittu-sddm-theme
      pkgs.kdePackages.qt5compat
      pkgs.kdePackages.qtdeclarative
      pkgs.kdePackages.qtsvg
      pkgs.kdePackages.qtmultimedia
    ];
  };

  environment.systemPackages = [
    ittu-sddm-theme
    pkgs.kdePackages.qt5compat
    pkgs.kdePackages.qtdeclarative
    pkgs.kdePackages.qtsvg
    pkgs.kdePackages.qtmultimedia
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
