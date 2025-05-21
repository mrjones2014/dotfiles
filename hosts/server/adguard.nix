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
      users = [
        {
          name = "mat";
          # generated with `nix-shell -p apacheHttpd` followed by `htpasswd -B -C 10 -n -b mat [password here]`
          # NB: Remember to put a space before the command so it doesn't go into shell history!
          password = "$2y$10$BKjlLZTCAgsfEO1L/TJFG.BiirZaHCE8NximCOdD7U5gCq9cz1x1C";
        }
      ];
      dns = {
        upstream_dns = [
          "https://dns.quad9.net/dns-query"
          "https://base.dns.mullvad.net/dns-query"
        ];
        anonymize_client_ip = false;
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
        rewrites = [
          {
            domain = "*.mjones.network";
            answer = import ./ip.nix;
          }
        ];
      };
      filters = map (url: {
        inherit url;
        enabled = true;
      }) filterLists;
      user_rules = [
        "||comparative-mollusk-y0a4rcrnmuyekxc7u0ajsvh7.herokudns.com^"
        "||telemetry.affine.run^"
      ];
    };
  };
}
