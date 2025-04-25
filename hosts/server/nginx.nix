{ config, lib, ... }:
let
  # Accept either an int or an attrset with at least a 'port' field
  subdomainType = lib.types.coercedTo
    lib.types.int
    (port: { inherit port; })
    (lib.types.submodule {
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
      };
    });

  cfg = config.services.nginx.subdomains;

  # Get all subdomain names where default = true
  defaultSubdomains = lib.filterAttrs (_: v: v.default or false) cfg;
in
{
  options.services.nginx.subdomains = lib.mkOption {
    type = lib.types.attrsOf subdomainType;
    description = ''
      Proxy the given subdomain to the specified port.
      You can specify either a port number, or an attribute set with a port and an optional "default" boolean.
    '';
    example = {
      "api" = 8080;
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
            forceSSL = true;
            useACMEHost = "mjones.network";
            default = cfg.${subdomain}.default or false;
            locations."/" = {
              proxyPass = "http://127.0.0.1:${toString cfg.${subdomain}.port}";
              proxyWebsockets = true;
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
