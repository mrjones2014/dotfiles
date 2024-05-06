{
  services = {
    deluge = {
      enable = true;
      web = {
        enable = true;
        port = 8112;
        openFirewall = true;
      };
    };
    prowlarr = {
      enable = true;
      openFirewall = true;
    };
    sonarr = {
      enable = true;
      openFirewall = true;
    };
    radarr = {
      enable = true;
      openFirewall = true;
    };
  };
}
