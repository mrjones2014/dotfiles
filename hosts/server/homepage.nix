{ config, ... }: {
  services.homepage-dashboard = {
    enable = true;
    openFirewall = true;
    environmentFile = config.age.secrets.homepage.path;
    settings = {
      theme = "dark";
      background =
        "https://images.unsplash.com/photo-1483347756197-71ef80e95f73?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D";
    };
    customCSS = ''
      li.service > div {
        backdrop-filter: blur(64px);
      }
    '';
    services = [
      {
        Media = [
          {
            Jellyfin = {
              icon = "jellyfin.svg";
              description = "Media Streaming";
              href = "https://jellyfin.mjones.network";
              target = "_self";
              widget = {
                type = "jellyfin";
                url = "http://localhost:8096";
                key = "{{HOMEPAGE_VAR_JELLYFIN_API_KEY}}";
                fields = [ "movies" "series" ];
                enableNowPlaying = false;
                enableBlocks = true;
              };
            };
          }
          {
            Jellyseerr = {
              icon = "jellyseerr.svg";
              description = "Content Management";
              href = "https://jellyseerr.mjones.network";
              target = "_self";
              widget = {
                type = "jellyseerr";
                url = "http://localhost:5055";
                key = "{{HOMEPAGE_VAR_JELLYSEERR_API_KEY}}";
              };
            };
          }
          {
            Deluge = {
              icon = "deluge.svg";
              description = "Torrent Status";
              widget = {
                type = "deluge";
                url = "http://localhost:8112";
                password = "{{HOMEPAGE_VAR_DELUGE_PASSWORD}}";
                fields = [ "leech" "download" ];
              };
            };
          }
          {
            NextDNS = {
              icon = "nextdns.svg";
              description = "NextDNS";
              href = "https://my.nextdns.io";
              target = "_self";
              widget = {
                type = "nextdns";
                profile = "7cac77";
                key = "{{HOMEPAGE_VAR_NEXTDNS_API_KEY}}";
              };
            };
          }
        ];
      }
      {
        Monitors = [
          {
            Calendar = {
              icon = "nextcloud-calendar.svg";
              widget = {
                type = "calendar";
                firstDayInWeek = "sunday";
                view = "monthly";
                showTime = true;
                timezone = "America/New_York";
                integrations = [
                  {
                    type = "sonarr";
                    service_group = "Monitors";
                    service_name = "Sonarr";
                  }
                  {
                    type = "radarr";
                    service_group = "Monitors";
                    service_name = "Radarr";
                  }
                ];
              };
            };
          }
          {
            Sonarr = {
              icon = "sonarr.svg";
              description = "Sonarr Monitors";
              widget = {
                type = "sonarr";
                url = "http://localhost:8989";
                key = "{{HOMEPAGE_VAR_SONARR_API_KEY}}";
              };
            };
          }
          {
            Radarr = {
              icon = "radarr.svg";
              description = "Radarr Monitors";
              widget = {
                type = "radarr";
                url = "http://localhost:7878";
                key = "{{HOMEPAGE_VAR_RADARR_API_KEY}}";
              };
            };
          }
        ];
      }
    ];
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
      {
        search = {
          provider = "custom";
          url = "https://kagi.com/search?q=";
          target = "_self";
        };
      }
    ];
  };
}
