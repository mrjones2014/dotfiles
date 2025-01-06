{ pkgs, config, ... }:
let port = 8888;
in {
  age.secrets.nextcloud_admin_pass = {
    file = ../../secrets/nextcloud_admin_pass.age;
    owner = "nextcloud";
    group = "nextcloud";
  };
  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud30;
    extraApps = {
      inherit (config.services.nextcloud.package.packages.apps)
        calendar cospend tasks groupfolders memories notes previewgenerator;
    };
    extraAppsEnable = true;
    configureRedis = true;
    maxUploadSize = "1G";
    hostName = "192.168.189.2";
    home = "/mnt/nextcloud";
    config.adminpassFile = config.age.secrets.nextcloud_admin_pass.path;
  };
  # see https://nixos.wiki/wiki/Nextcloud#Change_default_listening_port
  services.nginx.virtualHosts."192.168.189.2".listen = [{
    addr = "0.0.0.0";
    inherit port;
  }];
  networking.firewall = {
    allowedTCPPorts = [ port ];
    allowedUDPPorts = [ port ];
  };
}
