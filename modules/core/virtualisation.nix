{ pkgs, lib, config, ... }:
{
  # Only enable either docker or podman -- Not both
  virtualisation = {
    spiceUSBRedirection.enable = true;

    docker = {
      enable = false;
    };

    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };

    libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        runAsRoot = true;
        swtpm.enable = true;

      };
    };

    virtualbox.host = {
      enable = false; # vboxusers group access
      # Extension pack only enabled when VirtualBox is enabled (lazy evaluation)
      enableExtensionPack = if config.virtualisation.virtualbox.host.enable then true else false;
    };
  };

  services = {
    qemuGuest.enable = true;
    spice-vdagentd.enable = true;
    spice-webdavd.enable = true;
  };

  programs = {
    virt-manager.enable = true;
  };

  environment.systemPackages = with pkgs; [
    ctop
    virt-viewer
    spice
    spice-gtk
    spice-protocol
    virtio-win
    win-spice
    
    podman-desktop
    podman-compose
  ];
}
