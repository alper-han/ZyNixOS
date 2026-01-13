{ pkgs, host, ... }:
let
  inherit (import ../../hosts/${host}/variables.nix) networkInterface;
in
{
  services.irqbalance.enable = pkgs.lib.mkForce false;

  systemd.services.network-irq-affinity = {
    description = "Optimize network IRQ affinity for low latency (AMD 7950X)";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };

    script = ''
      IFACE="${networkInterface}"

      echo "Optimizing IRQs for interface: $IFACE"

      IRQS=$(grep "$IFACE" /proc/interrupts | awk '{print $1}' | tr -d :)

      CORE_IDX=0
      CORES=( "1" "2" "4" "8" "10" "20" "40" "80" )
      NUM_CORES=${"$"}{#CORES[@]}

      for IRQ in $IRQS; do
        if [ -n "$IRQ" ]; then
          MASK=${"$"}{CORES[$CORE_IDX]}
          echo "Pinning IRQ $IRQ to Core Mask $MASK"
          echo "$MASK" > /proc/irq/$IRQ/smp_affinity 2>/dev/null || echo "Failed to set affinity for $IRQ"
          
          CORE_IDX=$(( (CORE_IDX + 1) % NUM_CORES ))
        fi
      done
    '';
  };

  networking.localCommands = ''
    WAN_INTERFACE="${networkInterface}"

    UPLOAD_BANDWIDTH="940Mbit"
    DOWNLOAD_BANDWIDTH="940Mbit"

    TC="${pkgs.iproute2}/bin/tc"
    ETHTOOL="${pkgs.ethtool}/bin/ethtool"

    $ETHTOOL -K "$WAN_INTERFACE" \
      tso on gso on gro on sg on \
      rxvlan on txvlan on \
      rx-gro-hw on tx-nocache-copy on \
      2>/dev/null || true

    $ETHTOOL -G "$WAN_INTERFACE" rx 2048 tx 2048 2>/dev/null || true

    $ETHTOOL -A "$WAN_INTERFACE" rx off tx off 2>/dev/null || true

    $ETHTOOL --set-eee "$WAN_INTERFACE" eee off 2>/dev/null || true

    $TC qdisc del dev "$WAN_INTERFACE" root 2>/dev/null || true
    $TC qdisc del dev "$WAN_INTERFACE" ingress 2>/dev/null || true
    $TC qdisc del dev ifb0 root 2>/dev/null || true
    ip link del ifb0 2>/dev/null || true

    $TC qdisc add dev "$WAN_INTERFACE" root cake \
      bandwidth "$UPLOAD_BANDWIDTH" \
      besteffort nat nowash no-split-gso \
      ack-filter-aggressive dual-srchost internet raw

    ip link add name ifb0 type ifb
    ip link set dev ifb0 up
    ip link set dev ifb0 txqueuelen 1000
    
    $TC qdisc add dev "$WAN_INTERFACE" handle ffff: ingress
    $TC filter add dev "$WAN_INTERFACE" parent ffff: protocol all \
      u32 match u32 0 0 action mirred egress redirect dev ifb0

    $TC qdisc add dev ifb0 root cake \
      bandwidth "$DOWNLOAD_BANDWIDTH" \
      besteffort ingress nat wash split-gso \
      dual-dsthost internet raw
  '';
}
