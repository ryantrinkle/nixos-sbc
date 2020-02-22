{ nixpkgs ? import ./nixpkgs {}
, system ? "x86_64-linux"
}:

let
  evalNixos = configuration: import (nixpkgs.path + /nixos) {
    inherit system configuration;
  };

in (evalNixos ./aarch64-linux.nix).config.system.build.sdImage
