{ config, lib, pkgs, ... }:
let
  tuigreetArgs = [
    "--time"
    ''--time-format "%a, %d %b %Y - %H:%M"''
    "--remember"
    "--remember-session"
    "--asterisks"
    ''--theme "border=magenta;text=cyan;prompt=green;time=red;action=blue;button=yellow;container=black;input=red;greet=magenta"''
  ] ++ lib.optional (config.services.displayManager.defaultSession == "hyprland-uwsm") ''--cmd "uwsm start hyprland.desktop"'';
in
{

  console.colors = [

    "1C2133"
    "F27983"
    "A6E3A1"
    "F9E2AF"
    "89B4FA"
    "F38BA8"
    "94E2D5"
    "BAC2DE"
    "414559"
    "F27983"
    "A6E3A1"
    "F9E2AF"
    "89B4FA"
    "F38BA8"
    "94E2D5"
    "A6ADC8"
  ];

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
    # tuigreet + uwsm do not provide a reliable gkr-pam handoff here, so keep
    # the keyring available via D-Bus activation instead of a noisy PAM hook.
    enableGnomeKeyring = false;
    # greetd runs unconfined here, so pam_apparmor only generates change_hat denials.
    enableAppArmor = false;
  };
}
