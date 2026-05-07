{ pkgs, ... }:
{
  # Services to start
  services = {
    dbus.apparmor = "enabled";
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
      enable = true;
      package = pkgs.scx.full; # scx.rustscheds or scx.full
      scheduler = "scx_lavd"; # scx_lavd verified good for gaming
    };

    blueman.enable = true; # Bluetooth Support
    tumbler.enable = true; # Image/video preview
    journald.extraConfig = ''
      SystemMaxUse=1G
      MaxRetentionSec=14day
    '';
    logind.settings.Login.KillUserProcesses = true; # logout kill user process

    # Disabled unnecessary services
    printing.enable = false; # CUPS printing service
    avahi.enable = false; # mDNS/Bonjour
    geoclue2.enable = false; # Location service
    fwupd.enable = false; # Firmware update daemon

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
            # Keep Bluetooth audio on classic profiles/codecs for adapter stability.
            "bluez5.roles" = [
              "a2dp_sink"
              "a2dp_source"
              # "bap_sink"   # LE Audio Broadcast Audio Profile sink role.
              # "bap_source" # LE Audio Broadcast Audio Profile source role.
            ];
            "bluez5.codecs" = [
              "sbc"
              "sbc_xq"
              "aac"
              "ldac"
              "aptx"
              "aptx_hd"
              # "opus"              # PipeWire Bluetooth Opus codec.
              # "lc3"               # LE Audio LC3 codec.
              # "faststream"        # Low-latency Bluetooth audio codec/profile.
              # "faststream_duplex" # FastStream duplex mode for mic + playback.
            ];
            "bluez5.enable-sbc-xq" = true;
            "bluez5.enable-msbc" = true;
            "bluez5.hfphsp-backend" = "native";
          };
        };
        # Favor stable ALSA playback over gaming-style ultra-low latency.
        extraConfig."20-alsa-stability" = {
          "monitor.alsa.rules" = [
            {
              matches = [
                {
                  "node.name" = "~alsa_output\\..*";
                }
              ];
              actions = {
                "update-props" = {
                  "api.alsa.headroom" = 2048;
                  "api.alsa.period-size" = 1024;
                };
              };
            }
          ];
        };
      };
      # Optional global PipeWire latency tuning.
      # Kept disabled because rare cross-device crackle is more likely when the
      # graph runs on tighter-than-default quantum/request sizes.
      # extraConfig.pipewire."92-audio-stability" = {
      #   "context.properties" = {
      #     "default.clock.rate" = 48000;
      #     "default.clock.quantum" = 512;
      #     "default.clock.min-quantum" = 128;
      #     "default.clock.max-quantum" = 2048;
      #     "stream.properties" = {
      #        "resample.quality" = 10;
      #     };
      #   };
      # };
      # extraConfig.pipewire-pulse."92-audio-stability" = {
      #   "pulse.properties" = {
      #     "pulse.min.req" = "128/48000";
      #     "pulse.default.req" = "512/48000";
      #     "pulse.max.req" = "2048/48000";
      #     "pulse.min.quantum" = "128/48000";
      #     "pulse.max.quantum" = "2048/48000";
      #   };
      # };
    };
  };
}
