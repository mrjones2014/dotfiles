# Download LLMs per api
# curl http://localhost:11434/api/pull -d '{ "name": "llama2" }'
{ config, ... }:
let dataDir = "${config.users.users.mat.home}/open-webui";
in {
  systemd.tmpfiles.rules = [ "d ${dataDir} 055 nobody nobody - -" ];
  virtualisation = {
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };
    oci-containers = {
      backend = "podman";
      containers.open-webui = {
        autoStart = true;
        image = "ghcr.io/open-webui/open-webui";
        ports = [ "3000:8080" ];
        volumes = [ "${dataDir}:/app/backend/data" ];
        extraOptions = [
          "--network=host"
          "--add-host=host.containers.internal:host-gateway"
        ];
        environment = { OLLAMA_API_BASE_URL = "http://127.0.0.1:11434/api"; };
      };
    };
  };
  networking.firewall = { allowedTCPPorts = [ 80 443 8080 11434 3000 ]; };
}
