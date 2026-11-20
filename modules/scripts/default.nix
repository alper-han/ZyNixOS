{
  pkgs,
  lib,
  host,
  config,
  ...
}:
let
  inherit (import ../../hosts/${host}/variables.nix) terminal;
  scriptArgs = {
    inherit
      host
      terminal
      pkgs
      lib
      config
      ;
  };

  resolveFlake = import ./resolve-flake.nix { inherit pkgs; };

  scripts = [
    resolveFlake
    (import ./rebuild.nix { inherit host pkgs resolveFlake; })
    (import ./rollback.nix { inherit pkgs resolveFlake; })
    (import ./tmux-sessionizer.nix scriptArgs)
    (import ./driverinfo.nix scriptArgs)
  ];
in
{
  environment.systemPackages = scripts;
}
