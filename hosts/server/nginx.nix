{ config, lib, ... }:
let cfg = config.services.nginx.subdomains; in {
  options.services.nginx.subdomains = lib.mkOption {
    type = lib.types.attrsOf lib.types.port;
    description = "Proxy the given subdomain to the specified port.";
    example = {
      "myapp" = 8080;
      "api" = 9090;
    };
  };
  config = lib.mkIf (cfg != { }) {
    networking.firewall = {
      allowedTCPPorts = [ 80 443 ];
      allowedUDPPorts = [ 80 443 ];
    };
    age.secrets.cloudflare_certbot_token.file = ../../secrets/cloudflare_certbot_token.age;
    services.nginx = {
      enable = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;

      virtualHosts = lib.foldl'
        (acc: subdomain: acc // {
          "${subdomain}.mjones.network" = {
            forceSSL = true;
            locations."/".proxyPass = "http://127.0.0.1:${toString cfg.${subdomain}}";
            useACMEHost = "mjones.network";
          };
        })
        { }
        (lib.attrNames cfg);
    };
    security.acme = {
      acceptTerms = true;
      certs."mjones.network" = {
        inherit (config.services.nginx) group;
        email = "certs@mjones.network";
        domain = "*.mjones.network";
        dnsProvider = "cloudflare";
        dnsResolver = "1.1.1.1:53";
        environmentFile = config.age.secrets.cloudflare_certbot_token.path;
      };
    };
  };
}
