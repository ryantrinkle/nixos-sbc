{ config, pkgs, lib, ... }:
{

  imports = [
    ./pine64/a64-lts.nix
    ./arm.nix
    ./cross.nix
#    ./nixpkgs/nixos/modules/installer/cd-dvd/sd-image-raspberrypi.nix
  ];

  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;

  boot.consoleLogLevel = lib.mkDefault 7;

  nixpkgs.config.allowUnsupportedSystem = true;
  networking.wireless.enable = false;
#  services.xserver = {
#    enable = true;
#    displayManager.slim.enable = true;
#    desktopManager.gnome3.enable = true;
#    videoDrivers = [ "fbdev" ];
#  };
}
