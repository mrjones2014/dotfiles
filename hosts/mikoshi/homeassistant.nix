{ config, ... }:
let
  zwave_ui_port = 8998;
in
{
  networking.firewall = {
    # https://www.home-assistant.io/integrations/homekit/#firewall
    # https://home.mjones.network/configure/integrations/homekit for port numbers for my devices
    allowedTCPPorts = [
      21065
      21066
    ];
    allowedUDPPorts = [ 5353 ];
  };
  systemd.services.home-assistant = {
    after = [ "zwave-js-ui.service" ];
    wants = [ "zwave-js-ui.service" ];
  };
  services = {
    nginx.subdomains = {
      home.port = config.services.home-assistant.config.http.server_port;
      zwave.port = zwave_ui_port;
    };
    zwave-js-ui = {
      enable = true;
      serialPort = "/dev/ttyACM0";
      settings = {
        PORT = toString zwave_ui_port;
        trustProxy = "true";
      };
    };
    home-assistant = {
      enable = true;
      extraPackages =
        ps: with ps; [
          base36
          hap-python
          homekit-audio-proxy
          ical
          isal
          psycopg2
          pyatv
          pyipp
          universal-silabs-flasher
          zlib-ng
        ];
      extraComponents = [
        "default_config"
        "met"
        "esphome"
        "ring"
        "homekit"
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
        "automation ui" = "!include automations.yaml";
        "scene ui" = "!include scenes.yaml";
        "script ui" = "!include scripts.yaml";
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
