{
  config,
  lib,
  pkgs,
  ...
}:
let
  tuigreetArgs = [
    "--time"
    ''--time-format "%a, %d %b %Y - %H:%M"''
    "--remember"
    "--remember-session"
    "--asterisks"
    ''--theme "border=magenta;text=cyan;prompt=green;time=red;action=blue;button=yellow;container=black;input=red;greet=magenta"''
  ]
  ++ lib.optional (
    config.services.displayManager.defaultSession == "hyprland-uwsm"
  ) ''--cmd "uwsm start -e -D Hyprland hyprland.desktop"'';
in
{
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        user = "greeter";
        command = "${pkgs.tuigreet}/bin/tuigreet ${lib.concatStringsSep " " tuigreetArgs}";
      };
    };
  };
  environment.systemPackages = with pkgs; [ tuigreet ];

  security.pam.services.greetd = {
    enableGnomeKeyring = false;
    enableAppArmor = false;
  };
}
