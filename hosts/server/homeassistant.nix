{ config, ... }:
let
  zwave_ui_port = 8998;
in
{
  services = {
    nginx.subdomains = {
      home.port = config.services.home-assistant.config.http.server_port;
      zwave.port = zwave_ui_port;
    };
    zwave-js-ui = {
      enable = true;
      serialPort = "/dev/ttyACM0";
      settings.PORT = toString zwave_ui_port;
    };
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
        "zwave_js"
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
