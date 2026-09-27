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

  scripts = [
    (import ./rebuild.nix { inherit host pkgs; })
    (import ./rollback.nix scriptArgs)
    (import ./tmux-sessionizer.nix scriptArgs)
    (import ./driverinfo.nix scriptArgs)
  ];
in
{
  environment.systemPackages = scripts;
}
