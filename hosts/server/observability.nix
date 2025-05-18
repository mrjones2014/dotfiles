{ config, lib, ... }:
let
  homarrStateDir = "/var/lib/homarr";
  homarrPort = 9090;
  dashdotPort = 9091;
  gatusPort = 3001;

  # dynamically configure gatus status pages
  toTitleCase =
    str:
    let
      firstChar = builtins.substring 0 1 str;
      restChars = builtins.substring 1 (builtins.stringLength str) str;
    in
    lib.strings.toUpper firstChar + restChars;
  applyOverrides =
    overrides: subdomain:
    if lib.hasAttr subdomain overrides then overrides.${subdomain} else toTitleCase subdomain;
  nginxSubdomains = config.services.nginx.subdomains;
  subdomainOverrides = {
    # By default it will just capitalize the first letter
    # of the subdomain. Customize subdomain -> Title mapping here.
    qbittorrent = "qBitTorrent";
    home = "Home Assistant";
  };

  # Generate the Gatus endpoints configuration
  gatusEndpoints = lib.attrsets.mapAttrsToList (
    name: _:
    let
      title = applyOverrides subdomainOverrides name;
    in
    {
      name = title;
      url = "https://${name}.mjones.network";
      interval = "2m";
      conditions = [
        "[STATUS] == 200"
        "[RESPONSE_TIME] < 1500"
      ];
      alerts = [
        {
          enabled = true;
          type = "discord";
          failure-threshold = 4;
          success-threshold = 2;
          send-on-resolved = true;
          description = title;
        }
      ];
    }
  ) nginxSubdomains;
in
{
  services = {
    nginx.subdomains = {
      uptime.port = gatusPort;
      dashdot.port = dashdotPort;
      glances.port = config.services.glances.port;
      homarr = {
        port = homarrPort;
        default = true;
      };
    };

    gatus = {
      enable = true;
      environmentFile = config.age.secrets.gatus_discord_webhook_env.path;
      settings = {
        web.port = gatusPort;
        endpoints = gatusEndpoints;
        alerting.discord.webhook-url = "\${DISCORD_WEBHOOK_URL}";
      };
    };

    glances.enable = true;
  };

  age.secrets.gatus_discord_webhook_env.file = ../../secrets/gatus_discord_webhook_env.age;

  systemd.tmpfiles.rules = [ "d ${homarrStateDir} 0750 root root -" ];
  age.secrets.homarr_env.file = ../../secrets/homarr_env.age;
  virtualisation.oci-containers.containers.homarr = {
    autoStart = true;
    image = "ghcr.io/homarr-labs/homarr:latest";
    ports = [ "${builtins.toString homarrPort}:7575" ];
    volumes = [ "${homarrStateDir}:/appdata" ];
    environment.DEFAULT_COLOR_SCHEME = "dark";
    environmentFiles = [ config.age.secrets.homarr_env.path ];
  };

  virtualisation.oci-containers.containers.dashdot = {
    image = "mauricenino/dashdot";
    ports = [ "${builtins.toString dashdotPort}:3001" ];
    volumes = [ "/:/mnt/host:ro" ];
    extraOptions = [ "--privileged=true" ];
    environment = {
      DASHDOT_PAGE_TITLE = "Dashboard";
      DASHDOT_USE_IMPERIAL = "true";
      DASHDOT_ALWAYS_SHOW_PERCENTAGES = "true";
      DASHDOT_OVERRIDE_OS = "NixOS";
      DASHDOT_OVERRIDE_ARCH = "x86";
      DASHDOT_CUSTOM_HOST = "nixos-server";
      DASHDOT_SHOW_HOST = "true";
    };
  };
}
