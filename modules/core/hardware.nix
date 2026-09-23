{
  lib,
  pkgs,
  host,
  ...
}:
let
  inherit (import ../../hosts/${host}/variables.nix) hostname bluetoothSupport;
in
{
  hardware = {
    enableAllFirmware = false;
    graphics.enable = true;
    enableRedistributableFirmware = true;
    bluetooth = lib.mkIf bluetoothSupport {
      enable = true;
      powerOnBoot = true;
      settings = {
        General = {
          Name = hostname;
          ControllerMode = "dual";
          FastConnectable = true;
          # MT7925 Bluetooth audio is more reliable without experimental LE audio.
          # Experimental = true; # BlueZ userspace experimental features, including newer LE Audio paths.
          # Omit KernelExperimental entirely unless you have a UUID list to pass.
          # KernelExperimental = true; # Kernel-side experimental Bluetooth features for newer transports/codecs.
          Experimental = false;
          JustWorksRepairing = "always";
          SecureConnections = "on";
        };
        GATT = {
          Cache = "always";
          Channels = 3;
        };
        Policy = {
          AutoEnable = true;
          ReconnectAttempts = 7;
          ReconnectIntervals = "1,2,4,8,16,32,64";
          ResumeDelay = 1;
        };
      };
    };
  };

  # Leave rfkill untouched when the host disables Bluetooth.
  systemd.services.bluetooth-rfkill-unblock = lib.mkIf bluetoothSupport {
    description = "Unblock Bluetooth rfkill on boot";
    wantedBy = [ "bluetooth.service" ];
    before = [ "bluetooth.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.util-linux}/bin/rfkill unblock bluetooth";
      RemainAfterExit = true;
    };
  };
}
