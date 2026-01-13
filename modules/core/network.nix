{ host, pkgs, ... }:
let
  inherit (import ../../hosts/${host}/variables.nix) hostname;
in
{

  networking = {
    hostName = "${hostname}";
    networkmanager.enable = true;
    networkmanager.wifi.powersave = false;
    
    firewall = {
      enable = true;
      allowedTCPPorts = [ ];
      allowedUDPPorts = [ ];
      allowPing = true;
    };
  };

  boot = {
    kernelModules = [ "ifb" "tcp_bbr" ];

    kernel.sysctl = {
      # Virtual Memory Tweaks (64GB RAM Optimization)
      "vm.swappiness" = 10;                     # Delay swapping as long as possible
      "vm.vfs_cache_pressure" = 50;             # Keep filesystem cache in RAM longer
      "vm.dirty_bytes" = 536870912;             # 512MB dirty cache cap (prevents IO stutter)
      "vm.dirty_background_bytes" = 268435456;  # 256MB background writeback start

      # TCP hardening
      "kernel.sysrq" = 0;
      "net.ipv4.conf.default.rp_filter" = 1;
      "net.ipv4.conf.all.rp_filter" = 1;
      "net.ipv4.conf.default.send_redirects" = 0;
      "net.ipv4.conf.default.accept_redirects" = 0;
      "net.ipv4.conf.all.secure_redirects" = 0;
      "net.ipv4.conf.default.secure_redirects" = 0;
      "net.ipv6.conf.all.accept_redirects" = 0;
      "net.ipv6.conf.default.accept_redirects" = 0;
      "net.ipv4.tcp_syncookies" = 1;
      "net.ipv4.tcp_rfc1337" = 1;

      # BBR + ECN optimization (Kernel 6.x)
      "net.ipv4.tcp_congestion_control" = "bbr";
      "net.ipv4.tcp_ecn" = 1;
      "net.ipv4.tcp_ecn_fallback" = 1;

      # TCP ultra low latency
      "net.ipv4.tcp_fastopen" = 3;
      "net.ipv4.tcp_fin_timeout" = 30;
      "net.ipv4.tcp_window_scaling" = 1;
      "net.ipv4.tcp_mtu_probing" = 1;
      "net.ipv4.tcp_slow_start_after_idle" = 0;
      "net.ipv4.tcp_notsent_lowat" = 16384;

      # BBR pacing (Kernel 6.x)
      "net.ipv4.tcp_pacing_ss_ratio" = 200;
      "net.ipv4.tcp_pacing_ca_ratio" = 120;

      # Buffer optimization (1Gbps Optimized) - COMMENTED OUT FOR KERNEL 6.18+ AUTO-TUNING
      # "net.ipv4.tcp_rmem" = "4096 87380 67108864";
      # "net.ipv4.tcp_wmem" = "4096 65536 67108864";
      # "net.core.wmem_max" = 67108864;
      # "net.core.rmem_max" = 67108864;
      # "net.core.wmem_default" = 65536;
      # "net.core.rmem_default" = 87380;

      # Queue management
      "net.core.default_qdisc" = "fq";
      "net.core.netdev_max_backlog" = 1000;
      "net.core.somaxconn" = 2048;

      # Netdev budget (Kernel 6.x)
      # "net.core.netdev_budget" = 600;
      # "net.core.netdev_budget_usecs" = 8000;

      # Kernel Security Hardening (2026 Standards)
      "kernel.kptr_restrict" = 2;              # Hide kernel pointers (Exploit mitigation)
      "kernel.dmesg_restrict" = 1;             # Restrict dmesg access (Info leak prevention)
      "kernel.printk" = "3 3 3 3";             # Restrict kernel logging (Info leak prevention)
      "kernel.unprivileged_bpf_disabled" = 1;  # Restrict BPF to root (Attack surface reduction)
      "kernel.yama.ptrace_scope" = 1;          # Restrict ptrace (Process isolation)

      # BPF JIT compiler (performance boost & hardening)
      "net.core.bpf_jit_enable" = 1;
      "net.core.bpf_jit_harden" = 2;           # Strongest hardening (JIT Spraying protection)
      "net.core.bpf_jit_kallsyms" = 1;

      # IPv6
      "net.ipv6.conf.all.accept_ra" = 1;
    };
  };

  imports = [
    ./network-optimization.nix # network optimization
  ];

  systemd.services.NetworkManager-wait-online.enable = false;
  systemd.network.wait-online.enable = false;

  environment.systemPackages = with pkgs; [
    networkmanagerapplet
    iproute2
    ethtool
  ];
}
