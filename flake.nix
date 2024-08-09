{
  description = "Cookiecutter project template collection";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {inherit system;};
    in {
      lib.template = name: template: data:
        pkgs.stdenv.mkDerivation {
          name = "${name}";

          # Pass Json as file to avoid escaping
          passAsFile = ["jsonData"];
          jsonData = builtins.toJSON data;

          # Disable phases which are not needed. In particular the unpackPhase will
          # fail, if no src attribute is set
          phases = ["buildPhase" "installPhase"];

          buildPhase = ''
            ${pkgs.mustache-go}/bin/mustache $jsonDataPath ${template} > rendered_file
          '';

          installPhase = ''
            cp rendered_file $out
          '';
        };
    });
}
