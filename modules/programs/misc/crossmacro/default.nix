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

  services.crossmacro = {
    enable = true;
    users = [ username ];
  };
}
