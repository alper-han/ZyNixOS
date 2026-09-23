{
  config,
  lib,
  pkgs,
  ...
}:
{
  boot = {
    supportedFilesystems = [
      "ntfs"
      "exfat"
      "ext4"
      "vfat"
      "btrfs"
    ];
    tmp.cleanOnBoot = true;

    # Generic fallback; host hardware policy may intentionally override this.
    kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest-lto;
    kernelParams = [
      "preempt=full"
      # Avoid auto-activating raw GPT swap; declared swapDevices still use fstab.
      "systemd.gpt_auto=0"
      "zswap.enabled=0"
      "quiet"
      "splash"
      "boot.shell_on_fail"
      "udev.log_priority=3"
      "rd.systemd.show_status=auto"
    ];

    kernelModules = [ "ntsync" ];
    consoleLogLevel = 3;
    initrd = {
      enable = true;
      verbose = false;
      systemd.enable = true;
    };

    loader = {
      efi.canTouchEfiVariables = true;
      efi.efiSysMountPoint = "/boot";
      timeout = 5;
      systemd-boot.enable = false;
      grub = lib.mkMerge [
        {
          enable = true;
          configurationLimit = 5;
          device = "nodev";
          efiSupport = true;
          efiInstallAsRemovable = false;
          useOSProber = false;
          memtest86.enable = true;
          gfxmodeEfi = "auto";
        }
        (lib.mkIf config.boot.loader.grub.enable {
          theme = pkgs.stdenv.mkDerivation {
            pname = "distro-grub-themes";
            version = "3.1";
            src = pkgs.fetchFromGitHub {
              owner = "AdisonCavani";
              repo = "distro-grub-themes";
              rev = "v3.1";
              hash = "sha256-ZcoGbbOMDDwjLhsvs77C7G7vINQnprdfI37a9ccrmPs=";
            };
            installPhase = "cp -r customize/nixos $out";
          };
        })
      ];
    };

    plymouth = {
      enable = true;
      font = "${pkgs.dejavu_fonts}/share/fonts/truetype/DejaVuSans.ttf";
      themePackages = [ pkgs.catppuccin-plymouth ];
      theme = "catppuccin-macchiato";
    };

    binfmt.registrations.appimage = {
      wrapInterpreterInShell = false;
      interpreter = "${pkgs.appimage-run}/bin/appimage-run";
      recognitionType = "magic";
      offset = 0;
      mask = ''\xff\xff\xff\xff\x00\x00\x00\x00\xff\xff\xff'';
      magicOrExtension = ''\x7fELF....AI\x02'';
    };
  };
}
