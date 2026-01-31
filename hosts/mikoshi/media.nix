{ config, pkgs, ... }:
let
  huntarr_port = 9705;
  huntarr_data = "/var/lib/huntarr";
  sqlite-3-50 = pkgs.sqlite.overrideAttrs (old: {
    version = "3.50.0";
    src = pkgs.fetchurl {
      url = "https://sqlite.org/2025/sqlite-autoconf-3500000.tar.gz";
      sha256 = "09w32b04wbh1d5zmriwla7a02r93nd6vf3xqycap92a3yajpdirv";
    };
  });
in
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
    huntarr = {
      port = huntarr_port;
      useLongerTimeout = true;
    };
  };
  services = {
    jellyfin.enable = true;
    jellyseerr.enable = true;
    prowlarr.enable = true;
    sonarr = {
      enable = true;
      # Sonarr hangs after a while due to a sqlite issue:
      # https://github.com/nixos/nixpkgs/issues/481098
      # https://github.com/h0lylag/nix-config/commit/191876ec684efc0a937ad46acf25be242a7bc4b6
      package = pkgs.sonarr.override {
        sqlite = sqlite-3-50;
      };
    };
    radarr.enable = true;
    bazarr.enable = true;
  };

  systemd.tmpfiles.rules = [
    "d ${huntarr_data} 0755 root root -"
  ];
  virtualisation.oci-containers.containers.huntarr = {
    image = "huntarr/huntarr:latest";
    autoStart = true;
    ports = [ "${toString huntarr_port}:${toString huntarr_port}" ];
    volumes = [ "${huntarr_data}:/config" ];
    environment.TZ = "America/New_York";
  };
}
