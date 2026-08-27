{ pkgs, config, ... }:
{
  boot = {

    # Filesystems support
    supportedFilesystems = [
      "ntfs"
      "exfat"
      "ext4"
      "vfat"
      "btrfs"
    ];
    tmp.cleanOnBoot = true;

    # CachyOS Kernel Options (via xddxdd/nix-cachyos-kernel):
    # pkgs.cachyosKernels.linuxPackages-cachyos-latest-lto (generic x86_64)
    # pkgs.cachyosKernels.linuxPackages-cachyos-latest-lto-zen4 (AMD Zen4)
    # Other variants: _latest, _zen, _lqx, _xanmod_latest, _hardened, _rt
    kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest-lto;

    kernelParams = [
      "preempt=full" # lower latency but less throughput
      "systemd.swap=0" # disable GPT auto-discovered disk swap, keep zram-only strategy
      "zswap.enabled=0" # avoid double-compression path when zram is already enabled
      "quiet"
      "splash"
      "boot.shell_on_fail"
      "udev.log_priority=3"
      "rd.systemd.show_status=auto"
    ];

    kernelModules = [ "ntsync" ];

    # Optional next-step test if Bluetooth audio still crackles after the BlueZ changes:
    # extraModprobeConfig = ''
    #   options btusb enable_autosuspend=n
    # '';

    consoleLogLevel = 3;
    initrd = {
      enable = true;
      verbose = false;
      systemd.enable = true;
    };

    loader = {
      efi.canTouchEfiVariables = true;
      efi.efiSysMountPoint = "/boot";
      timeout = 1;
      systemd-boot = {
        enable = true;
        configurationLimit = 5;
        editor = false;
        consoleMode = "max";
        memtest86.enable = true;
      };
      grub = {
        enable = false;
        device = "nodev";
        efiSupport = true;
        useOSProber = false;
        memtest86.enable = true;
        gfxmodeEfi = "2715x1527"; # for 4k: 3840x2160
        gfxmodeBios = "2715x1527"; # for 4k: 3840x2160
        # Theme only builds when GRUB is enabled (lazy evaluation)
        theme =
          if config.boot.loader.grub.enable then
            pkgs.stdenv.mkDerivation {
              pname = "distro-grub-themes";
              version = "3.1";
              src = pkgs.fetchFromGitHub {
                owner = "AdisonCavani";
                repo = "distro-grub-themes";
                rev = "v3.1";
                hash = "sha256-ZcoGbbOMDDwjLhsvs77C7G7vINQnprdfI37a9ccrmPs=";
              };
              installPhase = "cp -r customize/nixos $out";
            }
          else
            null;
      };
    };

    plymouth = {
      enable = true;
      font = "${pkgs.dejavu_fonts}/share/fonts/truetype/DejaVuSans.ttf";
      themePackages = [ pkgs.catppuccin-plymouth ];
      theme = "catppuccin-macchiato";
    };

    # Appimage Support
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
