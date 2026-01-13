{ pkgs, config, ... }:

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
        command = ''
          ${pkgs.tuigreet}/bin/tuigreet \
            --time \
            --time-format "%a, %d %b %Y - %H:%M" \
            --remember \
            --remember-session \
            --asterisks \
            --theme "border=magenta;text=cyan;prompt=green;time=red;action=blue;button=yellow;container=black;input=red;greet=magenta" \
            --cmd "uwsm start hyprland-uwsm.desktop"
        '';
      };
    };
  };
  environment.systemPackages = with pkgs; [ tuigreet ];

  security.pam.services.greetd = {
    enableGnomeKeyring = true;
    enableAppArmor = config.security.apparmor.enable;
  };
}
