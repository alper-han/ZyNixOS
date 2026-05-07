{ pkgs, ... }:
{

  environment.systemPackages = with pkgs; [
    rustdesk
    # jellyfin-desktop
    # jellyfin-mpv-shim
    # kdiskmark
    # qbittorrent
    # mission-center
    # remmina # rdp&vnc

    # ffmpeg-full
    # chromium
    github-desktop
    # hoppscotch
    sqlitebrowser # db
    rider-fhs # dotnet / Avalonia / native UI dev
    dotnet-sdk_10
    dotnet-runtime_10
    dotnet-ef
  ];
}
