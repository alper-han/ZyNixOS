{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    jellyfin-desktop
    jellyfin-mpv-shim
    qbittorrent
    mission-center
    tor-browser
  ];
}
