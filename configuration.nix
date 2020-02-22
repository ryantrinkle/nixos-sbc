{ config, pkgs, lib, ... }:

with lib;

let # The virtual terminal the thermostat will run on.  A user connected via keyboard could press Ctrl+Alt+F<this number> to switch to it
    thermostatVT = "9";

in {

  imports = [
    ./pine64/a64-lts.nix
    ./arm.nix
    ./cross.nix
  ];
}
