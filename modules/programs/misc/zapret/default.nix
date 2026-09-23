{ ... }:
{
  # AdGuard owns DNS/port 53; Zapret handles DPI evasion only.
  services.zapret = {
    enable = true;
    params = [
      "--dpi-desync=fake"
      "--dpi-desync-ttl=8"
    ];
  };

}
