{ pkgs, ... }:
{
  # Services to start
  services = {
    libinput.enable = true; # Input Handling
    fstrim.enable = true; # SSD Optimizer
    devmon.enable = true; # For Mounting USB & More
    gvfs.enable = true; # For Mounting USB & More
    udisks2.enable = true; # For Mounting USB & More

    # Low Memory Protection (System Freeze Prevention)
    earlyoom = {
      enable = true;
      enableNotifications = true;
      freeMemThreshold = 5;
    };

    # Userspace CPU Scheduler for Improved Latency for Gaming (Hardware Specific)
    scx = {
      enable = false;
      package = pkgs.scx.full; # scx.rustscheds or scx.full
      scheduler = "scx_lavd"; # scx_lavd verified good for gaming
    };

    blueman.enable = true; # Bluetooth Support
    tumbler.enable = true; # Image/video preview
    logind.settings.Login.KillUserProcesses = true; # logout kill user process
    speechd.enable = false;

    # Disabled unnecessary services
    printing.enable = false;       # CUPS printing service
    avahi.enable = false;          # mDNS/Bonjour
    geoclue2.enable = false;       # Location service
    fwupd.enable = false;          # Firmware update daemon

    pulseaudio.enable = false;
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
      wireplumber = {
        enable = true;
        extraConfig."10-bluez" = {
          "monitor.bluez.properties" = {
            "bluez5.roles" = [
              "a2dp_sink"
              "a2dp_source"
              "bap_sink"
              "bap_source"
            ];
            "bluez5.codecs" = [
              "sbc"
              "sbc_xq"
              "aac"
              "ldac"
              "aptx"
              "aptx_hd"
              "opus"
              "lc3"
              "faststream"
              "faststream_duplex"
            ];
            "bluez5.enable-sbc-xq" = true;
            "bluez5.enable-msbc" = true;
            "bluez5.hfphsp-backend" = "native";
          };
        };
      };
      extraConfig.pipewire."92-low-latency" = {
        "context.properties" = {
          "default.clock.rate" = 48000;
          "default.clock.allowed-rates" = [ 44100 48000 88200 96000 ];
          "default.clock.quantum" = 1024;
          "default.clock.min-quantum" = 32;
          "default.clock.max-quantum" = 4096;
          "stream.properties" = {
             "resample.quality" = 10;
          };
        };
      };
      extraConfig.pipewire-pulse."92-low-latency" = {
        context.modules = [
          {
            name = "libpipewire-module-protocol-pulse";
            args = {
              pulse.min.req = "32/48000";
              pulse.default.req = "32/48000";
              pulse.max.req = "4096/48000";
              pulse.min.quantum = "32/48000";
              pulse.max.quantum = "4096/48000";
            };
          }
        ];
      };
    };
  };
}
