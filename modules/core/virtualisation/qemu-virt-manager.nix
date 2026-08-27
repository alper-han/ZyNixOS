{
  config,
  lib,
  pkgs,
  host,
  ...
}:
let
  inherit (import ../../../hosts/${host}/variables.nix) username;
in
{
  users.users.${username}.extraGroups = lib.optionals config.virtualisation.libvirtd.enable [
    "libvirtd"
    "kvm"
  ];

  virtualisation = {
    spiceUSBRedirection.enable = false;

    libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        runAsRoot = true;
        swtpm.enable = true;
      };
    };
  };

  # Guest integration daemons belong inside the VM guest, not on this VM host.
  services = lib.mkIf config.virtualisation.libvirtd.enable {
    qemuGuest.enable = false;
    spice-vdagentd.enable = false;
    spice-webdavd.enable = false;
  };

  programs.virt-manager.enable = config.virtualisation.libvirtd.enable;

  environment.systemPackages =
    with pkgs;
    lib.optionals config.virtualisation.libvirtd.enable [
      virt-viewer
      spice
      spice-gtk
      spice-protocol
      virtio-win
      win-spice
    ];
}
