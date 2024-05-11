{ config, ... }: {
  imports = [
    # port 8112
    ./deluge.nix
  ];
  services = {
    jellyfin = {
      enable = true;
      # see: https://jellyfin.org/docs/general/networking/index.html
      # ports are:
      # TCP: 8096, 8920
      # UDP: 1900 7359
      openFirewall = true;
    };
    # port 5055
    jellyseerr = {
      enable = true;
      openFirewall = true;
    };
    # port 9696
    prowlarr = {
      enable = true;
      openFirewall = true;
    };
    # port 8989
    sonarr = {
      enable = true;
      openFirewall = true;
    };
    # port 7878
    radarr = {
      enable = true;
      openFirewall = true;
    };
    # port 8082
    homepage-dashboard = {
      enable = true;
      openFirewall = true;
      settings = { theme = "dark"; };
      environmentFile = config.age.secrets.homepage.path;
      services = [{
        "Services" = [
          {
            "Jellyseerr" = {
              description = "Content Management";
              href = "https://jellyseerr.mjones.network";
              widget = {
                type = "jellyseerr";
                url = "https://jellyseerr.mjones.network";
                key = "{{HOMEPAGE_VAR_JELLYSEERR_API_KEY}}";
              };
            };

          }
          {
            "NextDNS" = {
              description = "NextDNS";
              href = "https://my.nextdns.io";
              widget = {
                type = "nextdns";
                profile = "7cac77";
                key = "{{HOMEPAGE_VAR_NEXTDNS_API_KEY}}";
              };
            };
          }
        ];
      }];
      widgets = [
        {
          resources = {
            label = "Load";
            cpu = true;
            memory = true;
          };
        }
        {
          resources = {
            label = "Disk (Jellyfin)";
            disk = "/mnt/jellyfin";
          };
        }
        {
          resources = {
            label = "Disk (Fileshare)";
            disk = "/mnt/fileshare";
          };
        }
      ];
    };
  };
}
