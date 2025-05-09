let
  filterLists = [
    "https://adguardteam.github.io/HostlistsRegistry/assets/filter_9.txt" # The Big List of Hacked Malware Web Sites
    "https://adguardteam.github.io/HostlistsRegistry/assets/filter_11.txt" # malicious url blocklist
    "https://big.oisd.nl"
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
    };
  };
}
