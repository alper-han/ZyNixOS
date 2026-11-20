{ pkgs, ... }:
let
  # .NET 10 + 11 side by side in one dotnet root (SDKs include their runtimes).
  # TODO: sdk_11_0 is RC in nixpkgs; drop this note once 11.0.100 GA lands.
  dotnet = pkgs.dotnetCorePackages.combinePackages [
    pkgs.dotnetCorePackages.sdk_10_0
    pkgs.dotnetCorePackages.sdk_11_0
  ];
in
{
  environment.sessionVariables = {
    DOTNET_ROOT = "${dotnet}/share/dotnet";
    DOTNET_ROOT_X64 = "${dotnet}/share/dotnet";
  };

  environment.systemPackages = with pkgs; [
    # rustdesk
    # jellyfin-desktop
    # jellyfin-mpv-shim
    # kdiskmark
    # qbittorrent
    # mission-center
    # remmina

    # ffmpeg-full
    # chromium
    # hoppscotch
    github-desktop
    sqlitebrowser
    jetbrains.rider # .NET / Avalonia development
    dotnet-sdk_11
    dotnet-runtime_11
    dotnet-ef
  ];
}
