{ pkgs, ... }:
{
  networking.networkmanager.dispatcherScripts = [
    {
      type = "basic";
      source = pkgs.writeShellScript "network-tuning" ''
        set -u

        IFACE="''${DEVICE_IFACE:-''${1:-}}"
        EVENT="''${2:-}"

        if [ -z "$IFACE" ] || [ "$EVENT" != "up" ]; then
          exit 0
        fi

        SYSFS="/sys/class/net/$IFACE"

        # Apply only to physical Ethernet devices. Interface names differ per
        # machine, so do not hardcode eno1/enp*/eth* here.
        if [ "$(cat "$SYSFS/type" 2>/dev/null || true)" != "1" ] \
          || [ -d "$SYSFS/wireless" ] \
          || [ ! -e "$SYSFS/device" ]; then
          exit 0
        fi

        ETHTOOL="${pkgs.ethtool}/bin/ethtool"

        # Report NIC capabilities only. Changes stay out of the declarative
        # baseline until a measured, interface-specific tuning decision exists.
        "$ETHTOOL" -k "$IFACE" >&2 || true
        "$ETHTOOL" --show-eee "$IFACE" >&2 || true
      '';
    }
  ];
}
