{ config, lib, ... }:
with lib;
let
  cfg = config.services.silverbullet;
  instanceOpts = { name, ... }: {
    options = {
      enable = mkEnableOption "SilverBullet instance ${name}";
      port = mkOption {
        type = types.port;
        description = "Port on which SilverBullet will listen";
        example = 9632;
      };
      subdomain = mkOption {
        type = types.str;
        description = "Subdomain for this SilverBullet instance";
        example = "sb";
      };
      environmentFiles = mkOption {
        type = types.listOf types.path;
        default = [ ];
        description = "List of environment files for the container";
        example = [ /path/to/env/file ];
      };
      indexPage = mkOption {
        type = types.str;
        default = "A: Home";
        description = "Default index page for SilverBullet";
      };
      dataDir = mkOption {
        type = types.str;
        default = "/var/lib/silverbullet/${name}";
        description = "Directory to store SilverBullet data";
      };
      domain = mkOption {
        type = types.str;
        default = "mjones.network";
        description = "Main domain name to use with the subdomain";
      };
    };
  };
in
{
  options.services.silverbullet.instances = mkOption {
    type = types.attrsOf (types.submodule instanceOpts);
    default = { };
    description = "SilverBullet instances configuration";
  };

  config = mkIf (cfg.instances != { }) {
    assertions = [
      {
        assertion = !config.services.silverbullet.enable;
        message = "Don't use the top-level enable option. Use `services.silverbullet.instances` instead.";
      }
    ];
    systemd.tmpfiles.rules = flatten (mapAttrsToList
      (name: instance:
        optional instance.enable "d ${instance.dataDir} 0770 root podman - -"
      )
      cfg.instances);

    virtualisation.oci-containers.containers = listToAttrs (
      mapAttrsToList
        (name: instance:
          nameValuePair "silverbullet-${name}" {
            image = "ghcr.io/silverbulletmd/silverbullet:v2";
            autoStart = true;
            ports = [ "${toString instance.port}:${toString instance.port}" ];
            volumes = [ "${instance.dataDir}:/space" ];
            inherit (instance) environmentFiles;
            environment = {
              SB_HOSTNAME = "0.0.0.0";
              SB_PORT = toString instance.port;
              SB_INDEX_PAGE = instance.indexPage;
            };
          }
        )
        (filterAttrs (name: instance: instance.enable) cfg.instances)
    );
    services.nginx = {
      enable = any (instance: instance.enable) (attrValues cfg.instances);
      virtualHosts = listToAttrs (
        mapAttrsToList
          (name: instance:
            nameValuePair "${instance.subdomain}.${instance.domain}" {
              forceSSL = true;
              useACMEHost = instance.domain;
              locations = {
                "/" = {
                  proxyPass = "http://127.0.0.1:${toString instance.port}";
                  proxyWebsockets = true;
                  extraConfig = ''
                    add_header Service-Worker-Allowed "/";
                  '';
                };

                # Cache config for offline functionality
                "/.config" = {
                  proxyPass = "http://127.0.0.1:${toString instance.port}";
                  extraConfig = ''
                    add_header Cache-Control "public, max-age=86400, immutable";
                    add_header Access-Control-Allow-Origin "*";
                  '';
                };

                # Cache static assets
                "~ \\.(css|js|png|jpg|woff2|svg)$" = {
                  proxyPass = "http://127.0.0.1:${toString instance.port}";
                  extraConfig = ''
                    add_header Cache-Control "public, max-age=604800";
                  '';
                };

                # Service worker with update control
                "/service-worker.js" = {
                  proxyPass = "http://127.0.0.1:${toString instance.port}";
                  extraConfig = ''
                    add_header Cache-Control "public, max-age=0";
                    add_header Service-Worker-Allowed "/";
                  '';
                };
              };
            }
          )
          (filterAttrs (name: instance: instance.enable) cfg.instances)
      );
    };
  };
}
