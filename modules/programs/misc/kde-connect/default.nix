{ ... }:
{
  programs.kdeconnect.enable = true;

  # Keep discovery/sessions LAN-only: accept private IPv4, ULA and link-local IPv6;
  # the nftables firewall drops all other sources.
  networking.firewall.extraInputRules = ''
    ip saddr { 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16, 169.254.0.0/16 } tcp dport 1714-1764 accept
    ip saddr { 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16, 169.254.0.0/16 } udp dport 1714-1764 accept
    ip6 saddr { fc00::/7, fe80::/10 } tcp dport 1714-1764 accept
    ip6 saddr { fc00::/7, fe80::/10 } udp dport 1714-1764 accept
  '';
}
