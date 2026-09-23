{
  config,
  host,
  lib,
  pkgs,
  ...
}:
let
  inherit (import ../../../hosts/${host}/variables.nix) username videoDriver;
  isNvidia = videoDriver == "nvidia";
in
{
  users.users.${username}.extraGroups = lib.optionals config.virtualisation.podman.enable [
    "podman"
  ];

  hardware.nvidia-container-toolkit.enable = isNvidia && config.virtualisation.podman.enable;

  virtualisation.podman = {
    enable = true;
    dockerCompat = false;
    defaultNetwork.settings.dns_enabled = true;
  };

  environment.systemPackages =
    with pkgs;
    lib.optionals config.virtualisation.podman.enable [
      ctop
      podman-desktop
      podman-compose
    ]
    ++ lib.optionals (isNvidia && config.virtualisation.podman.enable) [
      libnvidia-container
      nvidia-container-toolkit
    ];
}
