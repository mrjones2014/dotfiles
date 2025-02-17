{ pkgs, config, ... }:
let
  port = 8888;
  ip = import ./ip.nix;
in {
  age.secrets.nextcloud_admin_pass = {
    file = ../../secrets/nextcloud_admin_pass.age;
    owner = "nextcloud";
    group = "nextcloud";
  };
  environment.systemPackages = [ pkgs.ffmpeg_6 ];
  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud30;
    extraApps = {
      inherit (config.services.nextcloud.package.packages.apps)
        calendar cospend tasks groupfolders memories notes previewgenerator;
    };
    extraAppsEnable = true;
    autoUpdateApps.enable = true;
    phpOptions."opcache.interned_strings_buffer" = "23";
    configureRedis = true;
    maxUploadSize = "1G";
    hostName = ip;
    home = "/mnt/nextcloud";
    config = {
      adminpassFile = config.age.secrets.nextcloud_admin_pass.path;
      dbtype = "sqlite";
    };
    settings = {
      default_phone_region = "EN";
      enabled_preview_providers = [
        "OC\\Preview\\BMP"
        "OC\\Preview\\GIF"
        "OC\\Preview\\JPEG"
        "OC\\Preview\\Krita"
        "OC\\Preview\\MarkDown"
        "OC\\Preview\\MP3"
        "OC\\Preview\\MP4"
        "OC\\Preview\\OpenDocument"
        "OC\\Preview\\PNG"
        "OC\\Preview\\TXT"
        "OC\\Preview\\XBitmap"
        "OC\\Preview\\HEIC"
        "OC\\Preview\\Image"
        "OC\\Preview\\Movie"
      ];
      maintenance_window_start = 6;
      default_timezone = "America/New_York";
      force_locale = "en_US";
    };
  };
  # see https://nixos.wiki/wiki/Nextcloud#Change_default_listening_port
  services.nginx.virtualHosts."${ip}".listen = [{
    addr = "0.0.0.0";
    inherit port;
  }];
  networking.firewall = {
    allowedTCPPorts = [ port ];
    allowedUDPPorts = [ port ];
  };
}
