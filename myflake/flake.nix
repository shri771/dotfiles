{
  description = "Go 1.24 and Node.js 20 development environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs } @ inputs:
  let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in
  {
    # We group all system-specific outputs under the same attribute structure
    devShells.${system}.default = pkgs.mkShell {
      buildInputs = [
        pkgs.go_1_24
        pkgs.nodejs_20
        pkgs.gopls
      ];

      # shellHook = ''
      #   echo "✅ Dev Environment Loaded from Dotfiles"
      #   echo "Go: $(go version)"
      #   echo "Node: $(node --version)"
      # '';
    };

    packages.${system} = {
      hello = pkgs.hello;
      default = self.packages.${system}.hello;
    };
  };
}
