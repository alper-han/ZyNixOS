{
  host,
  inputs,
  ...
}:
let
  inherit (import ../../../../hosts/${host}/variables.nix)
    username
    ;
in
{
  imports = [
    inputs.crossmacro.nixosModules.default
  ];

  programs.crossmacro = {
    enable = true;
    users = [ "${username}" ];
  };
}
