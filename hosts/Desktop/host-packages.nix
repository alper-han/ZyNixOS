{ pkgs, ... }:
{

  # Host applications; shared CLI tools belong in modules/core/packages.nix.
  environment.systemPackages = with pkgs; [
    rustdesk
    # Optional packages
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
    sqlitebrowser
    jetbrains.rider # .NET / Avalonia development
    dotnet-sdk_10
    dotnet-runtime_10
    dotnet-ef
  ];
}
