{ ... }:
{
  services.duplicati = {
    enable = true;
    port = 8200;
    interface = "127.0.0.1";
    dataDir = "/var/lib/duplicati";
    # Keep backups under a dedicated account, not the desktop user.
    user = "duplicati";
  };

  systemd.services.duplicati.serviceConfig = {
    NoNewPrivileges = true;
    PrivateTmp = true;
    ProtectSystem = "strict";
    ProtectHome = "read-only";
    ReadWritePaths = [ "/var/lib/duplicati" ];
    RestrictAddressFamilies = [
      "AF_UNIX"
      "AF_INET"
      "AF_INET6"
    ];
  };
}
