{ pkgs, ... }:
{

  environment.systemPackages = with pkgs; [
    # kdiskmark
    # qbittorrent
    # mission-center
    # remmina # rdp&vnc
    rustdesk # remote desktop client
    # jellyfin-mpv-shim
    jellyfin-desktop

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
