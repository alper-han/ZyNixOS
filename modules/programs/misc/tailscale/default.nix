{ ... }:
{
  services.tailscale = {
    enable = true;
    disableUpstreamLogging = true;
    derper.enable = false;
    disableTaildrop = true;
    useRoutingFeatures = "client";
  };
}
