{
  host,
  lib,
  pkgs,
  ...
}:
let
  inherit (import ../../hosts/${host}/variables.nix) hostname bar;
in
{
  networking = {
    hostName = "${hostname}";
    networkmanager = {
      enable = true;
      wifi.powersave = false;
      plugins = with pkgs; [
        networkmanager-openvpn
      ];
    };

    firewall = {
      enable = true;
      # Loose reverse-path filtering keeps spoofing protection while allowing
      # VPNs, policy routing, and tunnel interfaces to use asymmetric paths.
      checkReversePath = "loose";
      allowedTCPPorts = [ ];
      allowedUDPPorts = [ ];
      allowPing = true;
    };
  };

  boot = {
    kernel.sysctl = {
      # Virtual Memory Tweaks (64GB RAM Optimization)
      "vm.swappiness" = 10; # Delay swapping as long as possible
      "vm.vfs_cache_pressure" = 50; # Keep filesystem cache in RAM longer
      "vm.dirty_bytes" = 536870912; # 512MB dirty cache cap (prevents IO stutter)
      "vm.dirty_background_bytes" = 268435456; # 256MB background writeback start

      # Network hardening
      "kernel.sysrq" = 0;
      "net.ipv4.conf.default.send_redirects" = 0;
      "net.ipv4.conf.all.send_redirects" = 0;
      "net.ipv4.conf.default.accept_redirects" = 0;
      "net.ipv4.conf.all.accept_redirects" = 0;
      "net.ipv4.conf.all.secure_redirects" = 0;
      "net.ipv4.conf.default.secure_redirects" = 0;
      "net.ipv6.conf.all.accept_redirects" = 0;
      "net.ipv6.conf.default.accept_redirects" = 0;
      "net.ipv4.tcp_syncookies" = 1;
      "net.ipv4.tcp_rfc1337" = 1;

      # BBR + ECN optimization for modern kernels. BBR relies on fq below for
      # pacing; CAKE/SQM belongs on the router when it controls the bottleneck.
      "net.ipv4.tcp_congestion_control" = "bbr";
      "net.ipv4.tcp_ecn" = 2;
      "net.ipv4.tcp_ecn_fallback" = 1;

      # TCP latency and reliability
      "net.ipv4.tcp_fastopen" = 1;
      "net.ipv4.tcp_mtu_probing" = 1;
      "net.ipv4.tcp_slow_start_after_idle" = 0;

      # Raise TCP/socket buffer ceilings for high-BDP apps without inflating
      # every socket's default memory footprint on a desktop system.
      "net.ipv4.tcp_rmem" = "4096 131072 33554432";
      "net.ipv4.tcp_wmem" = "4096 65536 33554432";
      "net.core.wmem_max" = 33554432;
      "net.core.rmem_max" = 33554432;

      # Queue management: fq is the host-side pacing qdisc for BBR. Do not use
      # global CAKE here; shape at the router/gateway only if bufferbloat tests fail.
      "net.core.default_qdisc" = "fq";
      "net.core.somaxconn" = 4096;

      # Kernel security hardening
      "kernel.kptr_restrict" = 2; # Hide kernel pointers (Exploit mitigation)
      "kernel.dmesg_restrict" = 1; # Restrict dmesg access (Info leak prevention)
      "kernel.printk" = "3 3 3 3"; # Restrict kernel logging (Info leak prevention)
      "kernel.unprivileged_bpf_disabled" = 1; # Restrict BPF to root (Attack surface reduction)
      "kernel.yama.ptrace_scope" = 1; # Restrict ptrace (Process isolation)

      # BPF JIT compiler (performance boost & hardening)
      "net.core.bpf_jit_enable" = 1;
      "net.core.bpf_jit_harden" = 2; # Strongest hardening (JIT Spraying protection)
      "net.core.bpf_jit_kallsyms" = 0;

      # IPv6
      "net.ipv6.conf.all.accept_ra" = 1;
    };
  };

  imports = [
    ./network-optimization.nix
  ];

  systemd.services.NetworkManager-wait-online.enable = false;
  systemd.network.wait-online.enable = false;

  environment.systemPackages =
    (with pkgs; [
      iproute2
      ethtool
      openvpn
      wireguard-tools
    ])
    ++ lib.optional (bar != "caelestia-shell") pkgs.networkmanagerapplet;
}
