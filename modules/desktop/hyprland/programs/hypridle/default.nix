{ host, ... }:
let
  inherit (import ../../../../../hosts/${host}/variables.nix) bar;
in
{
  home-manager.sharedModules = [
    (_: {
      services.hypridle = {
        enable = true;
        settings = {
          general = {
            ignore_dbus_inhibit = false;
            lock_cmd = "pidof hyprlock || uwsm app -- hyprlock";
            unlock_cmd = "pkill --signal SIGUSR1 hyprlock";
            before_sleep_cmd = "loginctl lock-session";
            after_sleep_cmd = "hyprctl dispatch dpms on";
          };
          listener = [
            {
              timeout = 600; # 10 Minutes
              on-timeout = "loginctl lock-session";
            }
            {
              timeout = 360; # 6 Minutes
              on-timeout = "hyprctl dispatch dpms off";
              on-resume =
                if bar == "caelestia-shell" then
                  "hyprctl dispatch dpms on"
                else
                  "hyprctl dispatch dpms on && sh -lc 'sleep 1; wallpaper'";
            }
            /*
              {
                timeout = 600; # 10m
                on-timeout = "systemctl suspend";
              }
            */
          ];
        };
      };
    })
  ];
}
