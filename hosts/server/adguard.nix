let
  filterLists = [
    # The Big List of Hacked Malware Web Sites
    "https://adguardteam.github.io/HostlistsRegistry/assets/filter_9.txt"
    # malicious url blocklist
    "https://adguardteam.github.io/HostlistsRegistry/assets/filter_11.txt"
    # https://oisd.nl, "passes the girlfriend test"
    "https://big.oisd.nl"
    # Native trackers (Windows, Apple, etc.)
    "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/pro.plus.txt"
  ];
  webuiPort = 9003;
in
{
  networking.firewall = {
    allowedTCPPorts = [ 53 ];
    allowedUDPPorts = [ 53 ];
  };
  services.nginx.subdomains.adguard.port = webuiPort;
  services.adguardhome = {
    enable = true;
    port = webuiPort;
    settings = {
      dns = {
        upstream_dns = [
          "https://dns.quad9.net/dns-query"
          "https://cloudflare-dns.com/dns-query"
        ];
        anonymize_client_ip = true;
      };
      tls = {
        enabled = true;
        server_name = "adguard.mjones.network";
        force_https = true;
        # since its behind a reverse proxy, nginx takes care of encryption
        allow_unencrypted_doh = true;
      };
      filtering = {
        protection_enabled = true;
        filtering_enabled = true;
      };
      filters = map (url: {
        inherit url;
        enabled = true;
      }) filterLists;
      user_rules = [
        "||telemetry.affine.run^"
      ];
    };
  };
}
