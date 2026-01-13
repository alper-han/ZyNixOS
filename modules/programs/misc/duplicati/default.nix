{
  host,
  ...
}:
let
  inherit (import ../../../../hosts/${host}/variables.nix)
    username
    ;
in
{
  services.duplicati = {
    enable = true;
    port = 8200;
    interface = "127.0.0.1";
    dataDir = "/var/lib/duplicati"; # Duplicati data dir
    user = "${username}";
  };
}
