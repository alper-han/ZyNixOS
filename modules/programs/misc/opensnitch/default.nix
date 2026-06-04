{ lib, pkgs, ... }:
let
  opensnitchUiDefaults = pkgs.writeShellApplication {
    name = "opensnitch-ui-defaults";
    runtimeInputs = [ pkgs.crudini ];
    text = ''
      settings="''${XDG_CONFIG_HOME:-$HOME/.config}/opensnitch/settings.conf"

      mkdir -p "$(dirname "$settings")"
      crudini --set "$settings" global default_duration 8
    '';
  };
in
{
  services.opensnitch = {
    enable = true;
    settings = {
      Firewall = "nftables";
      ProcMonitorMethod = "proc";
      InterceptUnknown = true;
      DefaultAction = "allow";
      Rules.Path = "/var/lib/opensnitch/rules";
      LogLevel = 2;
    };
  };

  environment.systemPackages = with pkgs; [
    opensnitch-ui
  ];

  systemd.user.services.opensnitch-ui = {
    description = "OpenSnitch UI";
    wantedBy = [ "graphical-session.target" ];
    wants = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStartPre = lib.getExe opensnitchUiDefaults;
      ExecStart = lib.getExe pkgs.opensnitch-ui;
      Restart = "on-failure";
      RestartSec = 2;
    };
  };
}
