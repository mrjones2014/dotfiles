{
  qbittorrent_port,
}:
{
  isServer,
  config,
  ...
}:
if isServer then
  {
    age.secrets.mullvad_wireguard.file = ../../secrets/mullvad_wireguard.age;
    services.nginx.subdomains.qbittorrent.port = qbittorrent_port;
    age.secrets.cross-seed-cfg.file = ../../secrets/cross_seed_cfg.age;
    services.cross-seed = {
      enable = true;
      # this gets merged with the `settings` nixos option
      settingsFile = config.age.secrets.cross-seed-cfg.path;
      settings = {
        host = "127.0.0.1";
        action = "inject";
        useClientTorrents = true;
        matchMode = "partial";
        seasonFromEpisodes = 0.5;
        linkDirs = [
          "/mnt/jellyfin/incomplete/cross-seed"
          "/mnt/jellyfin/media/cross-seed"
        ];
        outputDir = "/mnt/jellyfin/torrents/cross-seed";
        duplicateCategories = true;
      };
    };
  }
else
  { }
