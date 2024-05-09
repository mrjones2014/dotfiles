{
  services = {
    jellyfin = {
      enable = true;
      # see: https://jellyfin.org/docs/general/networking/index.html
      # ports are:
      # TCP: 8096, 8920
      # UDP: 1900 7359
      openFirewall = true;
    };
    jellyseerr = {
      enable = true;
      openFirewall = true;
    };
    deluge = {
      enable = true;
      web = {
        enable = true;
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
