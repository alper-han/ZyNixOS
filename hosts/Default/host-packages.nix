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
    # code-cursor
    # hoppscotch
    # antigravity-fhs
    # claude-code
    # opencode
    codex
    sqlitebrowser # db
    jetbrains.rider # dotnet
    dotnet-sdk_10
    dotnet-runtime_10
    dotnet-ef
  ];
}
