{
  description = "HexaTTD or Something";

  # Nixpkgs / NixOS version to use.
  inputs.nixpkgs.url = "https://channels.nixos.org/nixos-26.05/nixexprs.tar.zst";

  outputs = { self, nixpkgs }: let
    lastModifiedDate = self.lastModifiedDate or self.lastModified or "19700101";
    # Generate a user-friendly version number.
    version = builtins.substring 0 8 lastModifiedDate;
    # System types to support.
    supportedSystems = [
      "x86_64-linux"
      "x86_64-darwin"
      "aarch64-linux"
      "aarch64-darwin"
    ];
    # Helper function to generate an attrset '{ x86_64-linux = f "x86_64-linux"; ... }'.
    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    # Nixpkgs instantiated for supported system types.
    nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });
  in {
    # Provide some binary packages for selected system types.
    packages = forAllSystems ( system:
      let
        pkgs = nixpkgsFor.${system};
      in rec {
        hexattd-backend = pkgs.buildGoModule {
          pname = "HexaTTD-backend";
          inherit version;
          src = ./backend;

          vendorHash = "sha256-n2/gw9dA9h/LRFnkmDSooTcwcNFXh3PGogkRD3DSk7s=";
        };

        default = hexattd-backend;
      }
    );

    devShells = forAllSystems ( system:
      let
        pkgs = nixpkgsFor.${system};
      in {
        default = pkgs.mkShell {
          buildInputs = with pkgs; [
            go
            gopls
            gotools
            go-tools
          ];
        };
      }
    );
  };
}
