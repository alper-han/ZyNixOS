{ lib, pkgs, ... }:
{
  services.opensnitch = {
    enable = true;
    settings = {
      Firewall = "nftables";
      ProcMonitorMethod = "proc";
      InterceptUnknown = true;
      DefaultAction = "allow";
      DefaultDuration = "once";
      LogLevel = 2;
    };
  };

  environment.systemPackages = with pkgs; [
    opensnitch-ui
  ];

  # eBPF is incompatible with the custom CachyOS kernel, and audit mode breaks
  # activation on this system, so use proc mode.
  systemd.user.services.opensnitch-ui = {
    description = "OpenSnitch UI";
    wantedBy = [ "graphical-session.target" ];
    wants = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = lib.getExe pkgs.opensnitch-ui;
      Restart = "on-failure";
      RestartSec = 2;
    };
  };
}
