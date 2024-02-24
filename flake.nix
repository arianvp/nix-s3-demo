{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  nixConfig = {
    extra-substituters = [ "s3://cache20240224120542829900000001" ];
    extra-trusted-public-keys = [ "nix-s3-demo-1:ACTpMKf67tNWjV7D3AZLVlVA+Mm7O43fITgGJDM2dX0=" ];
  };

  outputs = { self, nixpkgs }: {
    devShells.aarch64-darwin.default = with nixpkgs.legacyPackages.aarch64-darwin; mkShell {
      buildInputs = [ opentofu awscli2 ];
    };
    packages.x86_64-linux.default = with nixpkgs.legacyPackages.x86_64-linux; stdenv.mkDerivation {
      name = "hello";
      src = ./.;
      buildPhase = "echo Hello, world! > $out";
    };
  };
}
