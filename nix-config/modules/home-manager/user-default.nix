{
  inputs,
  lib,
  config,
  pkgs,
  osConfig ? null,
  ...
}:

let
  # Custom wrapper for xdg-desktop-portal-termfilechooser.
  # The bundled ranger-wrapper.sh works but ranger's UX is opaque — there's
  # no on-screen hint that you rename a save target with `cw` or confirm a
  # directory by pressing `q` inside it. This wrapper prints an explicit
  # status-line message for each mode using ranger's --cmd flag.
  #
  # Portal arg contract (from xdg-desktop-portal-termfilechooser(5)):
  #   $1 multiple   $2 directory   $3 save   $4 path   $5 out   $6 verbosity
  rangerPortalWrapper = pkgs.writeShellScript "ranger-portal-wrapper" ''
    set -euo pipefail

    multiple="''${1:-0}"
    directory="''${2:-0}"
    save="''${3:-0}"
    path="''${4:-$HOME}"
    out="''${5:?missing out path}"

    if [ "''${6:-0}" -ge 4 ]; then set -x; fi

    # TERMCMD lets you swap kitty for foot/wezterm/etc. without rebuilding.
    # Default pinned to the kitty in this user profile.
    termcmd=(''${TERMCMD:-${pkgs.kitty}/bin/kitty --class ranger --title termfilechooser})
    ranger=${pkgs.ranger}/bin/ranger

    if [ "$save" = "1" ]; then
      # SAVE — termfilechooser pre-creates a placeholder at $path
      # (controlled by create_help_file=1 in the portal config, default on).
      #   - keep suggested name: navigate, Enter on the placeholder
      #   - rename:              cw   (or :rename <name>) then Enter
      #   - new name from scratch: :touch <name> then Enter on it
      #   - cancel:              q
      "''${termcmd[@]}" -e "$ranger" \
        --choosefile="$out" \
        --selectfile="$path" \
        --cmd='echo SAVE — cw renames, :touch NAME makes a new file, Enter confirms, q cancels'
    elif [ "$directory" = "1" ]; then
      # PICK DIRECTORY — --choosedir writes the dir ranger is INSIDE when it quits.
      "''${termcmd[@]}" -e "$ranger" \
        --choosedir="$out" \
        --show-only-dirs \
        --cmd='echo PICK DIR — open the target directory, then press q to confirm' \
        "$path"
    elif [ "$multiple" = "1" ]; then
      "''${termcmd[@]}" -e "$ranger" \
        --choosefiles="$out" \
        --cmd='echo MULTI — Space marks files, Enter confirms, q cancels' \
        "$path"
    else
      "''${termcmd[@]}" -e "$ranger" \
        --choosefile="$out" \
        --cmd='echo PICK FILE — Enter confirms, q cancels' \
        "$path"
    fi
  '';
in
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
        android_sdk.accept_license = true;
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

    services.cliphist.enable = true;

    xdg.configFile."systemd/user/graphical-session.target.wants/swaync.service".source =
      "${pkgs.swaynotificationcenter}/share/systemd/user/swaync.service";
    xdg.configFile."systemd/user/graphical-session.target.wants/hyprpolkitagent.service".source =
      "${pkgs.hyprpolkitagent}/share/systemd/user/hyprpolkitagent.service";

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
        "inode/directory" = "yazi.desktop";
      };
    };

    # Required for xdg.desktopEntries to actually write files into
    # ~/.local/share/applications/ — without this the option is a silent no-op.
    xdg.enable = true;

    xdg.configFile."autostart/picom.desktop".text = ''
      [Desktop Entry]
      Hidden=true
    '';

    # Yazi as the default file manager — desktop entry to launch it in kitty.
    # This is what `inode/directory` resolves to, so xdg-open on a folder
    # (and a Yazi mouse-open of a directory) lands in Yazi, not ranger.
    xdg.desktopEntries.yazi = {
      name = "Yazi";
      genericName = "File Manager";
      comment = "Blazing-fast terminal file manager";
      icon = "utilities-terminal";
      exec = "kitty --class yazi -e yazi %f";
      terminal = false; # kitty is the terminal; don't double-wrap
      categories = [
        "System"
        "FileTools"
        "FileManager"
        "Utility"
      ];
      mimeType = [ "inode/directory" ];
    };

    # Ranger kept available as a secondary file manager (no longer the default)
    xdg.desktopEntries.ranger = {
      name = "Ranger";
      genericName = "File Manager";
      comment = "Terminal file manager";
      icon = "utilities-terminal";
      exec = "kitty --class ranger -e ranger %f";
      terminal = false; # kitty is the terminal; don't double-wrap
      categories = [
        "System"
        "FileTools"
        "FileManager"
        "Utility"
      ];
      mimeType = [ "inode/directory" ];
    };

    # Hint apps that ask via env var which file manager to use
    home.sessionVariables = {
      FILE_MANAGER = "yazi";
      DEFAULT_FILE_MANAGER = "yazi";
      ANDROID_HOME = "$HOME/.nix-profile/libexec/android-sdk";
      ANDROID_SDK_ROOT = "$HOME/.nix-profile/libexec/android-sdk";
    };

    # Configure xdg-desktop-portal-termfilechooser to use ranger via our
    # custom wrapper (rangerPortalWrapper in the let block above), which adds
    # on-screen key hints the bundled wrapper lacks.
    # create_help_file=1 (the default, left implicit) is required so the SAVE
    # mode has a placeholder file the user can rename with `cw`.
    xdg.configFile."xdg-desktop-portal-termfilechooser/config".text = ''
      [filechooser]
      cmd=${rangerPortalWrapper}
      default_dir=$HOME
      open_mode=suggested
      save_mode=suggested
    '';

    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  };
}
