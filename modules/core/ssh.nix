{ host, ... }:
let
  inherit (import ../../hosts/${host}/variables.nix) username;
in
{
  services.openssh = {
    enable = true;
    # The feature module is opt-in; when enabled, expose SSH on the normal
    # port but require a key for the one declared local account.
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      AuthenticationMethods = "publickey";
      AllowUsers = [ username ];
      UseDns = false;
      X11Forwarding = false;
      PermitRootLogin = "no";
      AllowAgentForwarding = false;
      AllowTcpForwarding = "no";
      AllowStreamLocalForwarding = false;
      PermitTunnel = false;
      MaxAuthTries = 3;
      LoginGraceTime = "20s";
      ClientAliveInterval = 300;
      ClientAliveCountMax = 2;
    };
  };
}
