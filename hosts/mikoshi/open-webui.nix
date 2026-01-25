{ config, ... }:
{
  age.secrets.open_webui_env.file = ../../secrets/open_webui.age;
  services = {
    nginx.subdomains."ai".port = config.services.open-webui.port;
    ollama.enable = true;
    open-webui = {
      enable = true;
      environmentFile = config.age.secrets.open_webui_env.path;
    };
  };
}
