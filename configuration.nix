{ config, pkgs, lib, ... }:
{

  imports = [
    ./pine64/a64-lts.nix
    ./arm.nix
    ./cross.nix
  ];
}
