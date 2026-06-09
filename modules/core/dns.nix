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
            "https://cloudflare-dns.com/dns-query"
          ];
          upstream_mode = "parallel";
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
          upstream_timeout = "2s";
          cache_size = 134217728;
          cache_ttl_min = 300;
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
            {
              domain = "nixos-server";
              answer = "192.168.0.200";
              enabled = true;
            }
          ];

          parental_enabled = false;
          safe_search.enabled = false;
        };
        filters = [
          {
            enabled = true;
            id = 1780709973;
            name = "Malicious URL Blocklist (URLHaus)";
            url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_11.txt";
          }
          {
            enabled = true;
            id = 1780709974;
            name = "Phishing Army";
            url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_18.txt";
          }
          {
            enabled = true;
            id = 1780709975;
            name = "NoCoin Filter List";
            url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_8.txt";
          }
          {
            enabled = true;
            id = 1780709976;
            name = "Phishing URL Blocklist (PhishTank and OpenPhish)";
            url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_30.txt";
          }
          {
            enabled = true;
            id = 1780709977;
            name = "TUR: Turkish Ad Hosts";
            url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_40.txt";
          }
          {
            enabled = true;
            id = 1780709978;
            name = "TUR: turk-adlist";
            url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_26.txt";
          }
          {
            enabled = true;
            id = 1780709979;
            name = "HaGeZi's Ultimate Blocklist";
            url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_49.txt";
          }
        ];
      };
    };
  };
}
