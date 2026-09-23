{
  host,
  ...
}:
let
  inherit (import ../../../../hosts/${host}/variables.nix) username;
in
{
  services.crossmacro = {
    enable = true;
    users = [ username ];
  };
}
