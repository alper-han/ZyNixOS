{
  config,
  inputs,
  lib,
  pkgs,
  host,
  ...
}:
let
  inherit (import ../../../hosts/${host}/variables.nix) username;
in
{
  boot.kernelModules = [ "kvm-amd" ];

  users.users.${username}.extraGroups = lib.optionals config.virtualisation.libvirtd.enable [
    "libvirtd"
    "kvm"
  ];

  virtualisation = {
    spiceUSBRedirection.enable = false;

    libvirtd = {
      enable = true;
      qemu = {
        package = inputs.qemu-anti-detect.packages.${pkgs.stdenv.hostPlatform.system}.default;
        runAsRoot = false;
        swtpm.enable = true;
      };
    };
  };

  # libvirt's dnsmasq hands out guest IPs; NixOS firewall drops DHCP on bridges otherwise.
  networking.firewall.interfaces.virbr0.allowedUDPPorts = lib.mkIf config.virtualisation.libvirtd.enable [
    67
  ];

  programs.virt-manager.enable = config.virtualisation.libvirtd.enable;

  # Existing guests use NVMe/e1000e/VGA over VNC, so virtio-win and the SPICE guest tools
  # are not needed; virt-manager/virt-viewer already bring the SPICE client libraries.
  environment.systemPackages = lib.optionals config.virtualisation.libvirtd.enable [
    pkgs.virt-viewer
  ];
}
