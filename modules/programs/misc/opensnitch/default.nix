{
  config,
  lib,
  pkgs,
  ...
}:
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
  # The NixOS module's typed settings do not expose DefaultAction and
  # InterceptUnknown. Provide the complete daemon JSON so upstream defaults
  # cannot silently reintroduce allow-on-unknown behavior.
  opensnitchConfig = (pkgs.formats.json { }).generate "opensnitch-config.json" {
    Server = {
      Address = "unix:///tmp/osui.sock";
      Authentication = {
        Type = "simple";
        TLSOptions = {
          CACert = "";
          ServerCert = "";
          ClientCert = "";
          ClientKey = "";
          SkipVerify = false;
          ClientAuthType = "no-client-cert";
        };
      };
      LogFile = "/dev/stdout";
    };
    DefaultAction = "deny";
    DefaultDuration = "once";
    InterceptUnknown = true;
    ProcMonitorMethod = "proc";
    LogLevel = 2;
    LogUTC = true;
    LogMicro = false;
    Firewall = "nftables";
    FwOptions = {
      ConfigPath = "/etc/opensnitchd/system-fw.json";
      MonitorInterval = "15s";
      # Never bypass queued traffic when the firewall queue is saturated.
      QueueBypass = false;
    };
    Rules = {
      Path = "/var/lib/opensnitch/rules";
      EnableChecksums = false;
    };
    Stats = {
      MaxEvents = 250;
      MaxStats = 25;
      Workers = 6;
    };
    Internal = {
      GCPercent = 100;
      FlushConnsOnStart = true;
    };
  };
in
{
  assertions = [
    {
      assertion = config.networking.firewall.backend == "nftables";
      message = "OpenSnitch requires networking.firewall.backend = nftables";
    }
  ];

  services.opensnitch = {
    enable = true;
    configFile = opensnitchConfig;
    settings = {
      # Keep the declarative module metadata aligned with the daemon JSON and
      # the host firewall. Unknown traffic is denied until explicitly allowed.
      Firewall = "nftables";
      ProcMonitorMethod = "proc";
      Rules.Path = "/var/lib/opensnitch/rules";
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
