{ host, pkgs, ... }:
let
  inherit (import ../../hosts/${host}/variables.nix) username;
  flakePath = "/home/${username}/ZyNixOS";
in
{
  programs.nh = {
    enable = true;
    clean = {
      enable = true;
      extraArgs = "--keep-since 7d --keep 3";
    };
    flake = flakePath;
  };

  environment.systemPackages = with pkgs; [
    # nix-output-monitor
    nvd
    # vulnix
  ];
}
