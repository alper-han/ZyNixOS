{ pkgs, lib, config, host, ... }:
let
  inherit (import ../../hosts/${host}/variables.nix) username videoDriver;
  isNvidia = videoDriver == "nvidia";
in
{
  users.users.${username}.extraGroups =
    lib.optionals config.virtualisation.docker.enable [ "docker" ]
    ++ lib.optionals config.virtualisation.podman.enable [ "podman" ]
    ++ lib.optionals config.virtualisation.virtualbox.host.enable [ "vboxusers" ]
    ++ lib.optionals config.virtualisation.libvirtd.enable [ "libvirtd" "kvm" ];
  # Only enable either docker or podman -- Not both
  virtualisation = {
    spiceUSBRedirection.enable = true;

    docker = {
      enable = true;
      enableOnBoot = true;
      rootless = {
        enable = false;
        setSocketVariable = false;
      };
      autoPrune = {
        enable = true;
        dates = "weekly";
      };
    };

    podman = {
      enable = false;
      dockerCompat = false;
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

  services = lib.mkIf config.virtualisation.libvirtd.enable {
    qemuGuest.enable = true;
    spice-vdagentd.enable = true;
    spice-webdavd.enable = true;
  };

  programs.virt-manager.enable = config.virtualisation.libvirtd.enable;

  hardware.nvidia-container-toolkit.enable = isNvidia && (config.virtualisation.docker.enable || config.virtualisation.podman.enable);

  environment.systemPackages = with pkgs; lib.optionals config.virtualisation.libvirtd.enable [
    virt-viewer
    spice
    spice-gtk
    spice-protocol
    virtio-win
    win-spice
  ] ++ lib.optionals (config.virtualisation.docker.enable || config.virtualisation.podman.enable) [
    ctop
  ] ++ lib.optionals config.virtualisation.docker.enable [
    lazydocker
    docker-compose
  ] ++ lib.optionals isNvidia [
    libnvidia-container
    nvidia-container-toolkit
  ] ++ lib.optionals config.virtualisation.podman.enable [
    podman-desktop
    podman-compose
  ];
}
