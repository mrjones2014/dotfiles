{ config, lib, ... }:
let
  # Define the subdomain configuration options
  subdomainType = lib.types.submodule {
    options = {
      port = lib.mkOption {
        type = lib.types.nullOr lib.types.port;
        default = null;
        description = "Port to proxy to.";
      };
      redirectTo = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "If set, redirect all requests to this URL (301). Mutually exclusive with port.";
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
      allowLargeUploads = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether to allow large file uploads for this subdomain.";
      };
      address = lib.mkOption {
        type = lib.types.str;
        default = "127.0.0.1";
        description = "Address to proxy to (default: 127.0.0.1)";
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
        allowLargeUploads = true;
      };
    };
  };

  config = lib.mkIf (cfg != { }) {
    assertions = [
      {
        assertion = (lib.length (lib.attrNames defaultSubdomains)) <= 1;
        message = "Only one subdomain may have default = true.";
      }
      {
        assertion = lib.all (
          name:
          let
            s = cfg.${name};
          in
          (s.port != null && s.redirectTo == null) || (s.port == null && s.redirectTo != null)
        ) (lib.attrNames cfg);
        message = "Each subdomain must set exactly one of 'port' or 'redirectTo'.";
      }
    ];

    networking.firewall = {
      allowedTCPPorts = [
        80
        443
      ];
      allowedUDPPorts = [
        80
        443
      ];
    };
    age.secrets.cloudflare_certbot_token.file = ../../../secrets/cloudflare_certbot_token.age;
    services.nginx = {
      enable = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;
      recommendedBrotliSettings = true;
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      proxyTimeout = "180s";
      # send access logs to journal instead of /var/log/nginx/access.log
      commonHttpConfig = "access_log syslog:server=unix:/dev/log;";

      virtualHosts = lib.foldl' (
        acc: subdomain:
        let
          s = cfg.${subdomain};
        in
        acc
        // {
          "${subdomain}.mjones.network" = {
            inherit (s) default;
            forceSSL = true;
            useACMEHost = "mjones.network";
          }
          // (
            if s.redirectTo != null then
              {
                locations."/".return = "301 ${s.redirectTo}$request_uri";
              }
            else
              {
                locations."/" = {
                  proxyPass = "http://${s.address}:${toString s.port}";
                  proxyWebsockets = true;
                  extraConfig =
                    (lib.optionalString s.useLongerTimeout ''
                      proxy_read_timeout 120s;
                      proxy_connect_timeout 60s;
                      proxy_send_timeout 60s;
                    '')
                    + (lib.optionalString s.allowLargeUploads ''
                      client_max_body_size 1G;
                      proxy_request_buffering off;
                    '');
                };
              }
          );
        }
      ) { } (lib.attrNames cfg);
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
