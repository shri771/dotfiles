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
        "ssh"
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

    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  };
}

