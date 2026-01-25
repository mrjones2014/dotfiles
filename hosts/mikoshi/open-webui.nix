{ config, ... }:
{
  config.services = {
    nginx.subdomains."ai".port = config.services.open-webui.port;
    ollama.enable = true;
    open-webui = {
      enable = true;
      environment = {
        ANONYMIZED_TELEMETRY = "False";
        DO_NOT_TRACK = "True";
        SCARF_NO_ANALYTICS = "True";
        OLLAMA_API_BASE_URL = "http://127.0.0.1:${builtins.toString config.services.ollama.port}";
        DEFAULT_USER_ROLE = "pending";
        ENABLE_SIGNUP = "True";
      };
    };
  };
}
