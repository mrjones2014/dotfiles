{ config, ... }:
{
  imports = [ ../../nixos/qbittorrent.nix ];
  services.nginx.subdomains = {
    # jellyfin doesn't let you configure port via Nix, so just use the default value here
    # see: https://jellyfin.org/docs/general/networking/index.html
    jellyfin.port = 8096;
    jellyseerr.port = config.services.jellyseerr.port;
    prowlarr = {
      inherit (config.services.prowlarr.settings.server) port;
      useLongerTimeout = true;
    };
    sonarr = {
      inherit (config.services.sonarr.settings.server) port;
      useLongerTimeout = true;
    };
    radarr = {
      inherit (config.services.radarr.settings.server) port;
      useLongerTimeout = true;
    };
    bazarr = {
      port = config.services.bazarr.listenPort;
      useLongerTimeout = true;
    };
  };
  services = {
    jellyfin.enable = true;
    jellyseerr.enable = true;
    prowlarr.enable = true;
    sonarr.enable = true;
    radarr.enable = true;
    bazarr.enable = true;
  };
}
