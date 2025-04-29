{ config, lib, ... }:
let
  # Define the subdomain configuration options
  subdomainType = lib.types.submodule {
    options = {
      port = lib.mkOption {
        type = lib.types.port;
        description = "Port to proxy to.";
      };
      default = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether this is the default subdomain.";
      };
      useLongerTimeout = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether to use longer proxy timeout settings for this subdomain.";
      };
    };
  };

  cfg = config.services.nginx.subdomains;

  # Get all subdomain names where default = true
  defaultSubdomains = lib.filterAttrs (_: v: v.default) cfg;
in
{
  options.services.nginx.subdomains = lib.mkOption {
    type = lib.types.attrsOf subdomainType;
    description = ''
      Proxy the given subdomain to the specified port.
      Configure with an attribute set containing port and optional settings.
    '';
    example = {
      "api" = {
        port = 8080;
        useLongerTimeout = true;
      };
      "myapp" = {
        port = 9090;
        default = true;
      };
    };
  };

  config = lib.mkIf (cfg != { }) {
    assertions = [
      {
        assertion = (lib.length (lib.attrNames defaultSubdomains)) <= 1;
        message = "Only one subdomain may have default = true.";
      }
    ];

    networking.firewall = {
      allowedTCPPorts = [ 80 443 ];
      allowedUDPPorts = [ 80 443 ];
    };
    age.secrets.cloudflare_certbot_token.file = ../../secrets/cloudflare_certbot_token.age;
    services.nginx = {
      enable = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;
      proxyTimeout = "180s";

      virtualHosts = lib.foldl'
        (acc: subdomain: acc // {
          "${subdomain}.mjones.network" = {
            inherit (cfg.${subdomain}) default;
            forceSSL = true;
            useACMEHost = "mjones.network";
            locations."/" = {
              proxyPass = "http://127.0.0.1:${toString cfg.${subdomain}.port}";
              proxyWebsockets = true;
              extraConfig = lib.optionalString cfg.${subdomain}.useLongerTimeout ''
                proxy_read_timeout 120s;
                proxy_connect_timeout 60s;
                proxy_send_timeout 60s;
              '';
            };
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
