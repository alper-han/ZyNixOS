# Hyprland Startup Configuration: Environment Variables and Exec-once
# Usage: import ./startup.nix { inherit lib pkgs config defaultWallpaper; }
{
  lib,
  pkgs,
  isLaptop,
  bar,
}:
let
  inherit (lib) getExe getExe';
  batterynotify = pkgs.callPackage ./scripts/batterynotify.nix { };
in
{
  # Environment variables are handled in default.nix via xdg.configFile (UWSM)

  exec-once = [
    "dbus-update-activation-environment --systemd --all"
    "systemctl --user import-environment QT_QPA_PLATFORMTHEME QT_QPA_PLATFORM QT_WAYLAND_DISABLE_WINDOWDECORATION QT_AUTO_SCREEN_SCALE_FACTOR QT_ENABLE_HIGHDPI_SCALING XDG_CURRENT_DESKTOP XDG_SESSION_DESKTOP XDG_CONFIG_HOME"
    #"[workspace 1 silent] ${terminal}"
    #"[workspace 5 silent] ${browser}"
    #"[workspace special silent] ${browser} --private-window"
    #"[workspace special silent] ${terminal}"

    "uwsm app -s s -- ${bar}"
    # "wl-clipboard-history -t"
    "uwsm app -s b -- ${getExe' pkgs.wl-clipboard "wl-paste"} --type text --watch cliphist store" # clipboard store text data
    "uwsm app -s b -- ${getExe' pkgs.wl-clipboard "wl-paste"} --type image --watch cliphist store" # clipboard store image data
    "uwsm app -- ${getExe' pkgs.coreutils "rm"} -f \${XDG_CACHE_HOME:-$HOME/.cache}/cliphist/db" # Clear clipboard
    "uwsm app -s b -- kdeconnect-indicator"
    "hyprctl setcursor catppuccin-mocha-mauve-cursors 24"
  ]
  ++ lib.optionals (bar != "caelestia-shell") [
    "uwsm app -s b -- nm-applet --indicator"
  ]
  ++ lib.optionals isLaptop [
    "uwsm app -s b -- ${getExe batterynotify}" # battery notification
  ];
}
