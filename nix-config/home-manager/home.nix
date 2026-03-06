# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{ inputs, lib, config, pkgs, ... }: {
  # You can import other home-manager modules here
  imports = [
    ../modules/home-manager/setup_symlink.nix
    ../modules/home-manager/git_config.nix
    ../modules/home-manager/pkg.nix
  ];

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

  nixpkgs = {
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
      # Disable if you don't want unfree packages
      allowUnfree = true;
    };
  };

  # UserNmae
  home = {
    stateVersion = "23.11";
    username = "shri";
    homeDirectory = "/home/shri";
  };

  # Enable home-manager and git
  programs.git.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  services.gnome-keyring = {
    enable = true;
    components = [ "secrets" "ssh" "pkcs11" ];
  };

  home.sessionPath = [ "$HOME/go/bin" ];


  programs.home-manager.enable = true;
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
    extraArgs = [ "-w" "20" "-c" "10" "-d" "5" ];
  };
  systemd.user.services.batsignal.Install.WantedBy = lib.mkForce [ "default.target" ]; ## forcefully start


  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
}
