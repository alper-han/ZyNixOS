{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    rustdesk
    jellyfin-desktop
    jellyfin-mpv-shim
    # kdiskmark
    # qbittorrent
    # mission-center
    # remmina # rdp&vnc

    github-desktop
    # code-cursor
    # hoppscotch
    claude-code
    antigravity-fhs
    sqlitebrowser # db
    jetbrains.rider # dotnet
    dotnet-sdk_10
    dotnet-runtime_10
    dotnet-ef
  ];
}
