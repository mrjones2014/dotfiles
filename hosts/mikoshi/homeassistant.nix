{ config, pkgs, ... }:
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
      customComponents = [
        (pkgs.buildHomeAssistantComponent rec {
          owner = "jcwillox";
          domain = "climate_template";
          version = "1.4.0";
          src = pkgs.fetchFromGitHub {
            owner = "jcwillox";
            repo = "hass-template-climate";
            rev = "v${version}";
            hash = "sha256-InS4GUkQ6qoSdSkxz/V1LpMSNh0fsOefOFXCBOs6pXk=";
          };
        })
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

        climate = [
          {
            platform = "climate_template";
            name = "Window AC";
            unique_id = "window_ac_climate";
            modes = [
              "off"
              "cool"
            ];
            fan_modes = [
              "low"
              "medium"
              "high"
            ];
            min_temp = 61;
            max_temp = 86;
            temp_step = 1;

            # --- read state from the ESPHome entities ---
            hvac_mode_template = "{{ 'cool' if is_state('switch.office_lamp_ac_power', 'on') else 'off' }}";
            target_temperature_template = "{{ states('number.office_lamp_ac_temperature') | float(70) }}";
            fan_mode_template = "{{ {'1': 'low', '2': 'medium', '3': 'high'}.get(states('select.office_lamp_ac_fan_speed'), 'low') }}";

            # --- write actions to the ESPHome entities ---
            set_hvac_mode = [
              {
                service = "{{ 'switch.turn_on' if hvac_mode == 'cool' else 'switch.turn_off' }}";
                target.entity_id = "switch.office_lamp_ac_power";
              }
            ];
            set_temperature = [
              {
                service = "number.set_value";
                target.entity_id = "number.office_lamp_ac_temperature";
                data.value = "{{ temperature }}";
              }
            ];
            set_fan_mode = [
              {
                service = "select.select_option";
                target.entity_id = "select.office_lamp_ac_fan_speed";
                data.option = "{{ {'low': '1', 'medium': '2', 'high': '3'}[fan_mode] }}";
              }
            ];
          }
        ];
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
