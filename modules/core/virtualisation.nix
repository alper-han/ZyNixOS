{
  pkgs,
  lib,
  config,
  host,
  ...
}:
let
  inherit (import ../../hosts/${host}/variables.nix) username videoDriver;
  isNvidia = videoDriver == "nvidia";
in
{
  users.users.${username}.extraGroups =
    lib.optionals config.virtualisation.podman.enable [ "podman" ]
    ++ lib.optionals config.virtualisation.virtualbox.host.enable [ "vboxusers" ]
    ++ lib.optionals config.virtualisation.libvirtd.enable [
      "libvirtd"
      "kvm"
    ];
  # Only enable either docker or podman -- Not both
  virtualisation = {
    spiceUSBRedirection.enable = false;

    docker = {
      enable = true;
      enableOnBoot = true;
      rootless = {
        enable = true;
        setSocketVariable = true;
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
        runAsRoot = false;
        swtpm.enable = true;
      };
    };

    virtualbox.host = {
      enable = false; # vboxusers group access
      # Extension pack only enabled when VirtualBox is enabled (lazy evaluation)
      enableExtensionPack = if config.virtualisation.virtualbox.host.enable then true else false;
    };
  };

  # Guest integration daemons belong inside the VM guest, not on this VM host.
  services = lib.mkIf config.virtualisation.libvirtd.enable {
    qemuGuest.enable = false;
    spice-vdagentd.enable = false;
    spice-webdavd.enable = false;
  };

  programs.virt-manager.enable = config.virtualisation.libvirtd.enable;

  hardware.nvidia-container-toolkit.enable =
    isNvidia && (config.virtualisation.docker.enable || config.virtualisation.podman.enable);

  environment.systemPackages =
    with pkgs;
    lib.optionals config.virtualisation.libvirtd.enable [
      virt-viewer
      spice
      spice-gtk
      spice-protocol
      virtio-win
      win-spice
    ]
    ++ lib.optionals (config.virtualisation.docker.enable || config.virtualisation.podman.enable) [
      ctop
    ]
    ++ lib.optionals config.virtualisation.docker.enable [
      lazydocker
      docker-compose
    ]
    ++ lib.optionals isNvidia [
      libnvidia-container
      nvidia-container-toolkit
    ]
    ++ lib.optionals config.virtualisation.podman.enable [
      podman-desktop
      podman-compose
    ];
}
