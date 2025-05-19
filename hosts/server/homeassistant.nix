{ config, ... }:
{
  services = {
    nginx.subdomains.home.port = config.services.home-assistant.config.http.server_port;
    home-assistant = {
      enable = true;
      extraPackages =
        ps: with ps; [
          psycopg2
          pyatv
          universal-silabs-flasher
        ];
      extraComponents = [
        "default_config"
        "met"
        "esphome"
        "ring"
        "homekit_controller"
        "apple_tv"
        "brother"
        "adguard"
        "sonos"
        "nanoleaf"
        "api"
      ];
      config = {
        default_config = { };
        recorder.db_url = "postgresql://@/hass";
        homeassistant = {
          unit_system = "us_customary";
          time_zone = "America/New_York";
        };
        http = {
          trusted_proxies = [ "127.0.0.1" ];
          use_x_forwarded_for = true;
        };
      };
    };
    postgresql = {
      enable = true;
      ensureDatabases = [ "hass" ];
      ensureUsers = [
        {
          name = "hass";
          ensureDBOwnership = true;
        }
      ];
    };
  };
}
