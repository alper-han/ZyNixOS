{ pkgs, ... }:
{

  environment.systemPackages = with pkgs; [
    rustdesk
    # jellyfin-desktop
    # jellyfin-mpv-shim
    # kdiskmark
    # qbittorrent
    # mission-center
    # remmina

    # ffmpeg-full
    # chromium
    github-desktop
    # hoppscotch
    sqlitebrowser
    jetbrains.rider # .NET / Avalonia development
    dotnet-sdk_10
    dotnet-runtime_10
    dotnet-ef
  ];
}
