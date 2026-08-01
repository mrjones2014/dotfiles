{
  config,
  pkgs,
  ...
}:
let
  zwave_ui_port = 8998;
  ha-mcp = rec {
    version = "7.14.2";
    src = pkgs.fetchFromGitHub {
      owner = "homeassistant-ai";
      repo = "ha-mcp";
      rev = "v${version}";
      hash = "sha256-OWExvNsNwVZNM+jF2zOQnb7mTL4xu5JWm3Cd2BNL43g=";
    };
  };
  mkHaMcp =
    ps:
    ps.buildPythonPackage {
      pname = "ha-mcp";
      inherit (ha-mcp) version src;
      pyproject = true;

      build-system = [ ps.setuptools ];
      pythonRelaxDeps = true;

      dependencies =
        with ps;
        [
          cryptography
          fastmcp
          httpx
          packaging
          pydantic
          pydantic-monty
          python-dotenv
          truststore
          tzdata
          websockets
        ]
        ++ httpx.optional-dependencies.socks;

      doCheck = false;
      pythonImportsCheck = [ "ha_mcp" ];
    };
in
{
  networking.firewall = {
    # https://www.home-assistant.io/integrations/homekit/#firewall
    # https://home.mjones.network/configure/integrations/homekit for port numbers for my devices
    allowedTCPPorts = [
      21065
      21066
      9584
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
          (mkHaMcp ps)
          aiohttp
          base36
          hap-python
          homekit-audio-proxy
          ical
          isal
          psycopg2
          pyatv
          pyipp
          universal-silabs-flasher
          uv
          zlib-ng
        ];
      extraComponents = [
        "adguard"
        "api"
        "apple_tv"
        "brother"
        "default_config"
        "esphome"
        "homekit"
        "homekit_controller"
        "met"
        "nanoleaf"
        "ring"
        "sonos"
        "zwave_js"
      ];
      customComponents = [
        (pkgs.home-assistant-custom-components.ha_mcp_tools.overrideAttrs (
          oldAttrs:
          ha-mcp
          // {
            patches = (oldAttrs.patches or [ ]) ++ [ ./ha-mcp-tools-nix-managed-package.patch ];
          }
        ))
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
              "fan_only"
              "dry"
            ];
            fan_modes = [
              "low"
              "medium"
              "high"
            ];
            min_temp = 61;
            max_temp = 86;
            temp_step = 1;

            # read state from the ESPHome entities
            hvac_mode_template = "{{ 'off' if is_state('switch.office_lamp_ac_power', 'off') else {'e-save': 'auto', 'cool': 'cool', 'fan': 'fan_only', 'dry': 'dry'}.get(states('select.office_lamp_ac_mode'), 'cool') }}";
            target_temperature_template = "{{ states('number.office_lamp_ac_temperature') | float(70) }}";
            fan_mode_template = "{{ {'1': 'low', '2': 'medium', '3': 'high'}.get(states('select.office_lamp_ac_fan_speed'), 'low') }}";

            # write actions to the ESPHome entities
            set_hvac_mode = [
              # capture pre-action state
              {
                variables = {
                  was_off = "{{ is_state('switch.office_lamp_ac_power', 'off') }}";
                };
              }
              {
                service = "{{ 'switch.turn_off' if hvac_mode == 'off' else 'switch.turn_on' }}";
                target.entity_id = "switch.office_lamp_ac_power";
              }
              # stop here when turning off
              {
                condition = "template";
                value_template = "{{ hvac_mode != 'off' }}";
              }
              # wait for the power-on normalization ONLY if we actually powered on
              {
                choose = [
                  {
                    conditions = "{{ was_off }}";
                    sequence = [ { delay = "00:00:04"; } ];
                  }
                ];
              }
              {
                service = "select.select_option";
                target.entity_id = "select.office_lamp_ac_mode";
                data.option = "{{ {'auto': 'e-save', 'cool': 'cool', 'fan_only': 'fan', 'dry': 'dry'}[hvac_mode] }}";
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
                data.option = "{{ {'low': '1', 'medium': '2', 'high': '3'}.get(fan_mode, '1') }}";
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
