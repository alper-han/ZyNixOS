{
  config,
  lib,
  pkgs,
  host,
  ...
}:
let
  inherit (import ../../../hosts/${host}/variables.nix) videoDriver;
  isNvidia = videoDriver == "nvidia";
  containersEnabled = config.virtualisation.docker.enable || config.virtualisation.podman.enable;
in
{
  # Only enable either docker or podman -- Not both
  hardware.nvidia-container-toolkit.enable = isNvidia && containersEnabled;

  environment.systemPackages =
    with pkgs;
    lib.optionals containersEnabled [
      ctop
    ]
    ++ lib.optionals isNvidia [
      libnvidia-container
      nvidia-container-toolkit
    ];
}
