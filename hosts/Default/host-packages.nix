{ pkgs, ... }:
{

  environment.systemPackages = with pkgs; [
    rustdesk
    jellyfin-desktop
    # kdiskmark
    # qbittorrent
    # mission-center
    # remmina # rdp&vnc
    # jellyfin-mpv-shim

    # Terminal
    # yt-dlp

    # DEV
    github-desktop

    # code-cursor
    antigravity-fhs
    sqlitebrowser # db
    # hoppscotch

    jetbrains.rider # dotnet
    dotnet-sdk_10
    dotnet-runtime_10
    dotnet-ef
  ];
}
