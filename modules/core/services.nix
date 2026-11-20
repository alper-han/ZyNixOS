{
  host,
  lib,
  pkgs,
  ...
}:
let
  inherit (import ../../hosts/${host}/variables.nix) bluetoothSupport;
  bluezConfig = {
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
  alsaStabilityConfig = {
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
in
{
  services = {
    libinput.enable = true;
    fstrim.enable = true;

    # Do not auto-mount removable media. GVFS/UDisks remain available for an
    # explicit user mount through the desktop, with ACL-controlled /run/media.
    devmon.enable = false;
    gvfs.enable = true;
    udisks2 = {
      enable = true;
      mountOnMedia = false;
    };

    # Low Memory Protection: give interactive and AI workloads a warning phase
    # before SIGKILL while still acting well before the kernel OOM killer.
    earlyoom = {
      enable = true;
      enableNotifications = true;
      freeMemThreshold = 10;
      freeMemKillThreshold = 5;
      freeSwapThreshold = 10;
      freeSwapKillThreshold = 5;
    };

    scx-loader = {
      enable = true;
      config.default_sched = "scx_bpfland";
    };

    tumbler.enable = true; # Image/video preview
    journald.settings.Journal = {
      SystemMaxUse = "1G";
      MaxRetentionSec = "14day";
    };
    logind.settings.Login.KillUserProcesses = true;

    printing.enable = false;
    avahi.enable = false; # mDNS/Bonjour
    geoclue2.enable = false;
    fwupd.enable = false;
    speechd.enable = false; # On by default; drags in espeak-ng and ~650 MB of mbrola voices

    pulseaudio.enable = false;
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      wireplumber = {
        enable = true;
        # Omit BlueZ policy when the host disables Bluetooth.
        extraConfig =
          (lib.optionalAttrs bluetoothSupport {
            "10-bluez" = bluezConfig;
          })
          // {
            "20-alsa-stability" = alsaStabilityConfig;
          };
      };
      # Disabled: tighter PipeWire latency settings can cause cross-device crackle.
      # extraConfig.pipewire."92-audio-stability" = {
      #   "context.properties" = {
      #     "default.clock.rate" = 48000;
      #     "default.clock.quantum" = 512;
      #     "default.clock.min-quantum" = 128;
      #     "default.clock.max-quantum" = 2048;
      #     "stream.properties" = {
      #       "resample.quality" = 10;
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

  # earlyoom above is the OOM policy; disable the NixOS-default systemd-oomd
  # so two killers do not act on the same memory pressure.
  systemd.oomd.enable = false;
}
