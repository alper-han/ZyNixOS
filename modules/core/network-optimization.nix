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

        # Keep only reversible low-risk NIC latency knobs here. Do not force
        # IRQ affinity, ring sizes, offloads, or qdiscs without fresh measurements;
        # those are driver-specific and can regress throughput or latency.
        "$ETHTOOL" -A "$IFACE" rx off tx off 2>/dev/null || true
        "$ETHTOOL" --set-eee "$IFACE" eee off 2>/dev/null || true
      '';
    }
  ];
}
