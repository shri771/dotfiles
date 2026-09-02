{
  description = "Kyverno development shell — Go toolchain matching kyverno/go.mod";

  # Pinned to the same revision your system flake already uses, so it resolves
  # from the local store/cache instead of hitting the GitHub API (rate limits).
  inputs.nixpkgs.url = "github:nixos/nixpkgs/ffa10e26ae11d676b2db836259889f1f571cb14f";

  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          go_1_26 # kyverno go.mod requires go 1.26.6; if this pin is older,
          # Go's default GOTOOLCHAIN=auto fetches the exact version on build.
          gopls # LSP for Neovim
          gotools # goimports, etc.

          # interactive cluster/build tooling
          # (kyverno's `make` targets call their own pinned copies from ./.tools,
          #  so these versions never interfere with builds)
          kubectl
          kind
          kubernetes-helm
          gnumake
          git
        ];

        shellHook = ''
          # echo "🛡️  kyverno dev shell → $(go version | awk '{print $3}')"
        '';
      };
    };
}
