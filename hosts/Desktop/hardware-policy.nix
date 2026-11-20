{
  config,
  lib,
  pkgs,
  ...
}:
{
  boot.kernelModules = [
    "k10temp"
    "zenergy"
    "nct6775"
  ];
  boot.kernelParams = [
    "amd_pstate=active"
    "8250.nr_uarts=0"

    # MT7925 Bluetooth Fix
    "usbcore.autosuspend=-1"
  ];
  boot.extraModprobeConfig = ''
    options mt7925e disable_aspm=1
  '';
  boot.extraModulePackages = [
    config.boot.kernelPackages.zenergy
  ];
  boot.kernelPackages = lib.mkForce (pkgs.cachyosKernels.linuxPackages-cachyos-latest-lto-zen4.extend (final: prev: {
  # boot.kernelPackages = lib.mkForce (pkgs.linuxPackages_latest.extend (final: prev: {
    kernel = prev.kernel.overrideAttrs (old: {
      patches = (old.patches or []) ++ [
        ../../modules/core/virtualisation/patches/kvm-cpl3-ud.patch
      ];
    });
  })); # pkgs.cachyosKernels.linuxPackages-cachyos-latest-lto-zen4;
}
