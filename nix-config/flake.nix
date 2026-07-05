{
  description = "Your new nix config";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    # You can access packages and modules from different nixpkgs revs
    # at the same time. Here's an working example:
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    # Also see the 'unstable-packages' overlay at 'overlays/default.nix'.

    # Home manager
    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";

    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      ...
    }@inputs:
    let
      pkgsFor =
        system:
        import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
            android_sdk.accept_license = true;
          };
        };
      # Supported systems for your flake packages, shell, etc.
      systems = [
        "aarch64-linux"
        "i686-linux"
        "x86_64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
      # This is a function that generates an attribute by calling a function you
      # pass to it, with each system as an argument
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      # Your custom packages
      # Accessible through 'nix build', 'nix shell', etc
      packages = forAllSystems (system: import ./pkgs nixpkgs.legacyPackages.${system});
      # Formatter for your nix files, available through 'nix fmt'
      # Other options beside 'alejandra' include 'nixpkgs-fmt'
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);

      # Your custom packages and modifications, exported as overlays
      overlays = import ./overlays { inherit inputs; };
      # Reusable nixos modules you might want to export
      # These are usually stuff you would upstream into nixpkgs
      nixosModules = import ./modules/nixos;
      # Reusable home-manager modules you might want to export
      # These are usually stuff you would upstream into home-manager
      homeManagerModules = import ./modules/home-manager;

      # NixOS configuration entrypoint
      # Available through 'nixos-rebuild --flake .#your-hostname'
      nixosConfigurations = {
        shri-nix = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs;
            primaryUser = "shri";
          };
          modules = [
            inputs.disko.nixosModules.disko
            ./nixos/configuration.nix
            ./nixos/hardware.nix
            ./nixos/disk-config.nix
          ];
        };

        # Custom live ISO: Hyprland + GDM + dotfiles + offline install
        iso = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs;
            primaryUser = "shri";
          };
          modules = [
            ./nixos/configuration.nix
            ./nixos/iso.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit inputs; };
              home-manager.users.shri = import ./home-manager/shri-home.nix;
              home-manager.users.tst = import ./home-manager/tst-home.nix;
            }
          ];
        };
      };

      # Standalone home-manager configuration entrypoint
      # Available through 'home-manager --flake .#your-username@your-hostname'
      homeConfigurations = {
        "shri@shri-nix" = home-manager.lib.homeManagerConfiguration {
          # Home-manager requires 'pkgs' instance
          pkgs = pkgsFor "x86_64-linux";
          extraSpecialArgs = { inherit inputs; };
          modules = [
            # > Our main home-manager configuration file <
            ./home-manager/shri-home.nix
          ];
        };
        "tst@shri-nix" = home-manager.lib.homeManagerConfiguration {
          # Home-manager requires 'pkgs' instance
          pkgs = pkgsFor "x86_64-linux";
          extraSpecialArgs = { inherit inputs; };
          modules = [
            # > Our main home-manager configuration file <
            ./home-manager/tst-home.nix
          ];
        };
      };
    };
}
