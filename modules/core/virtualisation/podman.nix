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
  users.users.${username}.extraGroups = lib.optionals config.virtualisation.podman.enable [
    "podman"
  ];

  virtualisation.podman = {
    enable = true;
    dockerCompat = false;
    defaultNetwork.settings.dns_enabled = true;
  };

  environment.systemPackages =
    with pkgs;
    lib.optionals config.virtualisation.podman.enable [
      podman-desktop
      podman-compose
    ];
}
