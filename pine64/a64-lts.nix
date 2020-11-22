# Support Pine64 A64-LTS board
{ config, pkgs, ... }:
let
  extlinux-conf-builder =
    import <nixpkgs/nixos/modules/system/boot/loader/generic-extlinux-compatible/extlinux-conf-builder.nix> {
      pkgs = pkgs.buildPackages;
    };
in
{
  imports = [
    <nixpkgs/nixos/modules/installer/cd-dvd/sd-image.nix>
  ];

  sdImage = {
    populateFirmwareCommands = let
      configTxt = pkgs.writeText "config.txt" ''
        kernel=u-boot-rpi3.bin

        # Boot in 64-bit mode.
        arm_control=0x200

        # U-Boot used to need this to work, regardless of whether UART is actually used or not.
        # TODO: check when/if this can be removed.
        enable_uart=1

        # Prevent the firmware from smashing the framebuffer setup done by the mainline kernel
        # when attempting to show low-voltage or overtemperature warnings.
        avoid_warnings=1
      '';
      in ''
        (cd ${pkgs.raspberrypifw}/share/raspberrypi/boot && cp bootcode.bin fixup*.dat start*.elf $NIX_BUILD_TOP/firmware/)
        cp ${pkgs.ubootRaspberryPi3_64bit}/u-boot.bin firmware/u-boot-rpi3.bin
        cp ${configTxt} firmware/config.txt
      '';
    populateRootCommands = ''
      mkdir -p ./files/boot
      ${extlinux-conf-builder} -t 3 -c ${config.system.build.toplevel} -d ./files/boot
    '';
  };

  nixpkgs.overlays = [(self: super: {
    linux_5_9 = super.linux_latest.override {
      argsOverride = rec {
        src = import ./linux/thunk.nix;
        version = "5.9.1";
        modDirVersion = version;
      };
    };
    linuxPackages_5_9 = self.linuxPackagesFor self.linux_5_9;
  })];

  boot.initrd.availableKernelModules = [
    # Allows early (earlier) modesetting for the Raspberry Pi
    "vc4" "bcm2835_dma" "i2c_bcm2835"
    # Allows early (earlier) modesetting for Allwinner SoCs
    "sun4i_drm" "sun8i_drm_hdmi" "sun8i_mixer"
  ];

  boot.kernelPackages = pkgs.linuxPackages_5_9;
  boot.kernelPatches = [
    { name = "fix-ethernet";
      patch = ./fix-ethernet.patch;
    }
    { name = "enable-lcd";
      patch = ./enable-lcd.patch;
    }
    { name = "disable-mmc-ddr";
      patch = ./disable-mmc-ddr.patch;
    }
  ];
}
