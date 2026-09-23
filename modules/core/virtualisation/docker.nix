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
  users.users.${username}.extraGroups = lib.optionals config.virtualisation.docker.enable [
    "docker"
  ];

  hardware.nvidia-container-toolkit.enable = isNvidia && config.virtualisation.docker.enable;

  virtualisation.docker = {
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

  environment.systemPackages =
    with pkgs;
    lib.optionals config.virtualisation.docker.enable [
      ctop
      lazydocker
      docker-compose
    ]
    ++ lib.optionals (isNvidia && config.virtualisation.docker.enable) [
      libnvidia-container
      nvidia-container-toolkit
    ];
}
