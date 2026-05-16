{
  inputs,
  lib,
  config,
  pkgs,
  osConfig ? null,
  ...
}:

{
  config = {
    # home-manager.backupFileExtension = "backup"; # Removed from here

    # Only set nixpkgs options in standalone mode.
    # When used as a NixOS module with useGlobalPkgs, the system's
    # nixpkgs config (overlays, allowUnfree) is inherited automatically.
    nixpkgs = lib.mkIf (osConfig == null) {
      # You can add overlays here
      overlays = [
        # Add overlays your own flake exports (from overlays and pkgs dir):
        inputs.self.overlays.additions
        inputs.self.overlays.modifications
        inputs.self.overlays.unstable-packages

        # You can also add overlays exported from other flakes:
        # neovim-nightly-overlay.overlays.default
      ];
      # Configure your nixpkgs instance
      config = {
        home-manager.backupFileExtension = "backup"; # Correct placement
        # Disable if you don't want unfree packages
        allowUnfree = true;
      };
    };

    # Nicely reload system units when changing configs
    systemd.user.startServices = "sd-switch";

    services.gnome-keyring = {
      enable = true;
      components = [
        "secrets"
        # "ssh"
        "pkcs11"
      ];
    };

    home.sessionPath = [ "$HOME/go/bin" ];

    programs.home-manager = {
      enable = true;
    };
    programs.neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;

      # extraPackages = with pkgs; [
      #   # Additional LSP servers and tools
      #   nodePackages.typescript-language-server
      #   nodePackages.vscode-langservers-extracted
      # ];
    };

    # Low battery waring
    services.batsignal = {
      enable = true;
      extraArgs = [
        "-w"
        "20"
        "-c"
        "10"
        "-d"
        "5"
      ];
    };
    systemd.user.services.batsignal.Install.WantedBy = lib.mkForce [ "default.target" ]; # # forcefully start

    # KDE
    services.kdeconnect = {
      enable = true;
      indicator = true; # shows the tray icon on non-Plasma desktops
    };

    # Default applications for file types
    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        # Images
        "image/png" = "org.gnome.Loupe.desktop";
        "image/jpeg" = "org.gnome.Loupe.desktop";
        "image/gif" = "org.gnome.Loupe.desktop";
        "image/webp" = "org.gnome.Loupe.desktop";
        "image/bmp" = "org.gnome.Loupe.desktop";
        "image/tiff" = "org.gnome.Loupe.desktop";
        "image/svg+xml" = "org.gnome.Loupe.desktop";

        # Video
        "video/mp4" = "vlc.desktop";
        "video/x-matroska" = "vlc.desktop";
        "video/webm" = "vlc.desktop";
        "video/avi" = "vlc.desktop";
        "video/x-msvideo" = "vlc.desktop";

        # Audio
        "audio/mpeg" = "vlc.desktop";
        "audio/flac" = "vlc.desktop";
        "audio/ogg" = "vlc.desktop";
        "audio/x-wav" = "vlc.desktop";
        "audio/mp4" = "vlc.desktop";

        # Browser
        "text/html" = "vivaldi-stable.desktop";
        "x-scheme-handler/http" = "vivaldi-stable.desktop";
        "x-scheme-handler/https" = "vivaldi-stable.desktop";
        "x-scheme-handler/about" = "vivaldi-stable.desktop";
        "x-scheme-handler/unknown" = "vivaldi-stable.desktop";

        # PDF
        "application/pdf" = "vivaldi-stable.desktop";

        # Documents (LibreOffice)
        "application/vnd.oasis.opendocument.text" = "writer.desktop";
        "application/vnd.openxmlformats-officedocument.wordprocessingml.document" = "writer.desktop";
        "application/vnd.oasis.opendocument.spreadsheet" = "calc.desktop";
        "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" = "calc.desktop";

        # Archives
        "application/zip" = "org.kde.ark.desktop";
        "application/x-tar" = "org.kde.ark.desktop";
        "application/gzip" = "org.kde.ark.desktop";
        "application/x-7z-compressed" = "org.kde.ark.desktop";
        "application/x-rar" = "org.kde.ark.desktop";

        # Text
        "text/plain" = "nvim.desktop";

        # File manager
        "inode/directory" = "ranger.desktop";
      };
    };

    # Ranger as the default file manager — desktop entry to launch it in kitty
    xdg.desktopEntries.ranger = {
      name = "Ranger";
      genericName = "File Manager";
      comment = "Terminal file manager";
      icon = "utilities-terminal";
      exec = "kitty --class ranger -e ranger %f";
      terminal = false; # kitty is the terminal; don't double-wrap
      categories = [ "System" "FileTools" "FileManager" "Utility" ];
      mimeType = [ "inode/directory" ];
    };

    # Hint apps that ask via env var which file manager to use
    home.sessionVariables = {
      FILE_MANAGER = "ranger";
      DEFAULT_FILE_MANAGER = "ranger";
    };

    # Configure xdg-desktop-portal-termfilechooser to use ranger.
    # The package ships a ready-made ranger-wrapper.sh that invokes
    # `kitty --title 'termfilechooser' -e ranger ...` with the right flags
    # for open / open-multiple / save / pick-directory.
    xdg.configFile."xdg-desktop-portal-termfilechooser/config".text = ''
      [filechooser]
      cmd=${pkgs.xdg-desktop-portal-termfilechooser}/share/xdg-desktop-portal-termfilechooser/ranger-wrapper.sh
      default_dir=$HOME
      open_mode=suggested
      save_mode=suggested
    '';

    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  };
}
