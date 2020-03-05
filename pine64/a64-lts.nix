# Support Pine64 A64-LTS board
{ config, pkgs, ... }:
let
  extlinux-conf-builder =
    import ../nixpkgs/nixos/modules/system/boot/loader/generic-extlinux-compatible/extlinux-conf-builder.nix {
      pkgs = pkgs.buildPackages;
    };
in
{
  imports = [
    ../nixpkgs/nixos/modules/installer/cd-dvd/sd-image.nix
  ];

  sdImage = {
    populateFirmwareCommands = let
      configTxt = pkgs.writeText "config.txt" ''
        # Prevent the firmware from smashing the framebuffer setup done by the mainline kernel
        # when attempting to show low-voltage or overtemperature warnings.
        avoid_warnings=1

        [pi0]
        kernel=u-boot-rpi0.bin

        [pi1]
        kernel=u-boot-rpi1.bin
      '';
      in ''
        (cd ${pkgs.raspberrypifw}/share/raspberrypi/boot && cp bootcode.bin fixup*.dat start*.elf $NIX_BUILD_TOP/firmware/)
        cp ${pkgs.ubootRaspberryPiZero}/u-boot.bin firmware/u-boot-rpi0.bin
        cp ${pkgs.ubootRaspberryPiZero}/u-boot.bin firmware/u-boot-rpi1.bin
        cp ${configTxt} firmware/config.txt
      '';
    populateRootCommands = ''
      mkdir -p ./files/boot
      ${extlinux-conf-builder} -t 3 -c ${config.system.build.toplevel} -d ./files/boot
    '';
  };

  nixpkgs.overlays = [(self: super: {
    # Does not cross-compile...
    alsa-firmware = pkgs.runCommandNoCC "neutered-firmware" {} "mkdir -p $out";
  }) (self: super: {
    linux_5_5 = super.linux_latest.override {
      argsOverride = rec {
        src = self.fetchFromGitHub {
          owner = "torvalds";
          repo = "linux";
          rev = "46cf053efec6a3a5f343fead837777efe8252a46";
          sha256 = "1fpqxc42bvmlrjn5xbyj7xiy1xni3gsaxlsdzhmkk4x0whba1h6m";
        };
        version = "5.5.0-rc3";
        modDirVersion = version;
      };
    };
    linuxPackages_5_5 = self.linuxPackagesFor self.linux_5_5;
  })];

  boot.initrd.availableKernelModules = [
    # Allows early (earlier) modesetting for the Raspberry Pi
    "vc4" "bcm2835_dma" "i2c_bcm2835"
    # Allows early (earlier) modesetting for Allwinner SoCs
    "sun4i_drm" "sun8i_drm_hdmi" "sun8i_mixer"
  ];

  boot.kernelPackages = pkgs.linuxPackages_rpi;
#  boot.kernelPatches = [
#    { name = "display";
#      patch = ./drm-sun4i-Allwinner-A64-MIPI-DSI-support.patch;
#    }
#    { name = "panel";
#      patch = ./DO-NOT-MERGE-v9-8-9-arm64-dts-allwinner-a64-pine64-lts-Enable-Feiyang-FY07024DI26A30-D-DSI-panel.patch;
#    }
#    { name = "touch";
#      patch = ./enable-touchscreen.patch;
#    }
#  ];
}
