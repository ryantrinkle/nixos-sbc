{ lib, ... }:
with lib;
{
  nixpkgs.crossSystem.system = "aarch64-linux";

  # There's a problem running fc-cache
  environment.noXlibs = mkDefault true;

  # gobject-introspection seems tough to cross-compile.
  # See, e.g., https://github.com/Guacamayo/meta-gir
  security.polkit.enable = false;
  services.udisks2.enable = false;

  # cifs-utils fails to cross-compile
  # Let's simplify this by removing all unneeded filesystems from the image.
  boot.supportedFilesystems = mkForce [ "vfat" ];
}
