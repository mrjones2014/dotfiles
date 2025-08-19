{ config, lib, ... }:
{
  age.secrets.open-webui-env.file = ../../secrets/open_webui_env.age;
  services = {
    nginx.subdomains.ai.port = config.services.open-webui.port;
    open-webui = {
      enable = true;
      port = 65534;
      environmentFile = config.age.secrets.open-webui-env.path;
    };
    ollama.enable = true;
  };
}
