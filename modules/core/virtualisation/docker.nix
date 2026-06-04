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
  users.users.${username}.extraGroups = lib.optionals config.virtualisation.docker.enable [
    "docker"
  ];

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
      lazydocker
      docker-compose
    ];
}
