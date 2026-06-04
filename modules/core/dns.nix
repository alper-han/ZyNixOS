{ ... }:
{
  networking = {
    firewall = {
      allowedTCPPorts = [ ];
      allowedUDPPorts = [ ];
    };

    nameservers = [
      "::1"
      "127.0.0.1"
    ];

    networkmanager.dns = "none";
  };

  services = {
    adguardhome = {
      enable = true;
      host = "127.0.0.1";
      port = 3005;
      mutableSettings = false;
      openFirewall = false;
      settings = {
        http = {
          address = "127.0.0.1:3005";
        };
        log = {
          enabled = false;
        };
        querylog = {
          enabled = false;
          file_enabled = false;
          interval = "24h";
          size_memory = 0;
        };
        statistics = {
          enabled = false;
          interval = "24h";
        };
        dns = {
          bind_hosts = [
            "127.0.0.1"
            "::1"
          ];
          port = 53;
          allowed_clients = [
            "127.0.0.1"
            "::1"
          ];
          upstream_dns = [
            "https://dns.quad9.net/dns-query"
          ];
          bootstrap_dns = [
            "9.9.9.9"
            "149.112.112.112"
            "2620:fe::fe"
            "2620:fe::9"
            "1.1.1.1"
            "1.0.0.1"
            "2606:4700:4700::1111"
            "2606:4700:4700::1001"
          ];
          fallback_dns = [
            "https://cloudflare-dns.com/dns-query"
          ];
          cache_size = 67108864;
          cache_ttl_min = 60;
          cache_optimistic = true;
        };
        filtering = {
          protection_enabled = true;
          filtering_enabled = true;
          rewrites_enabled = true;
          rewrites = [
            {
              domain = "*.orange.pi";
              answer = "192.168.0.200";
              enabled = true;
            }
          ];

          parental_enabled = false;
          safe_search.enabled = false;
        };
        filters =
          map
            (url: {
              enabled = true;
              url = url;
            })
            [
              "https://adguardteam.github.io/HostlistsRegistry/assets/filter_11.txt"
              "https://adguardteam.github.io/HostlistsRegistry/assets/filter_18.txt"
              "https://adguardteam.github.io/HostlistsRegistry/assets/filter_8.txt"
              "https://adguardteam.github.io/HostlistsRegistry/assets/filter_30.txt"
              "https://adguardteam.github.io/HostlistsRegistry/assets/filter_40.txt"
              "https://adguardteam.github.io/HostlistsRegistry/assets/filter_26.txt"
              "https://adguardteam.github.io/HostlistsRegistry/assets/filter_49.txt"
            ];
      };
    };
  };
}
