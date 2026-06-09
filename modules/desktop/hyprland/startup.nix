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
  barCommand = if bar == "caelestia-shell" then "caelestia shell -d" else bar;
in
{
  # Environment variables are handled by UWSM env files in default.nix.
  # UWSM exports those files to the systemd user and D-Bus activation
  # environments, so duplicating dbus-update-activation-environment or
  # systemctl import-environment here is unnecessary.

  exec-once = [
    #"[workspace 1 silent] ${terminal}"
    #"[workspace 5 silent] ${browser}"
    #"[workspace special silent] ${browser} --private-window"
    #"[workspace special silent] ${terminal}"

    "uwsm app -s s -- ${barCommand}"
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
