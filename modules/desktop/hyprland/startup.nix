# Hyprland Startup Configuration: Environment Variables and Exec-once
# Usage: import ./startup.nix { inherit lib pkgs config defaultWallpaper; }
{
  lib,
  pkgs,
  config,
  defaultWallpaper,
}:
let
  inherit (lib) getExe getExe';
  wallpaper = pkgs.callPackage ./scripts/wallpaper.nix { inherit defaultWallpaper; };
  batterynotify = pkgs.callPackage ./scripts/batterynotify.nix { };
in
{
  # Environment variables are handled in default.nix via xdg.configFile (UWSM)

  exec-once = [
    #"[workspace 1 silent] ${terminal}"
    #"[workspace 5 silent] ${browser}"
    #"[workspace special silent] ${browser} --private-window"
    #"[workspace special silent] ${terminal}"

    "uwsm app -- ${lib.getExe wallpaper}"
    "uwsm app -- waybar"
    "uwsm app -- nm-applet --indicator"
    # "wl-clipboard-history -t"
    "uwsm app -- ${getExe' pkgs.wl-clipboard "wl-paste"} --type text --watch cliphist store" # clipboard store text data
    "uwsm app -- ${getExe' pkgs.wl-clipboard "wl-paste"} --type image --watch cliphist store" # clipboard store image data
    "uwsm app -- rm '$XDG_CACHE_HOME/cliphist/db'" # Clear clipboard
    "uwsm app -- ${getExe batterynotify}" # battery notification
    "uwsm app -- kdeconnect-indicator"
    "uwsm app -- wl-clip-persist --clipboard regular"
    "hyprctl setcursor rose-pine-hyprcursor 24"
  ];
}
