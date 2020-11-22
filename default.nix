{ nixpkgs ? import ./nixpkgs {}
}:
{
  module = {
    pine64.a64-lts = ./pine64/a64-lts.nix;
    cross = ./cross.nix;
    arm = ./arm.nix;
  };
}
