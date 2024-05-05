# Download LLMs per api
# curl http://localhost:11434/api/pull -d '{ "name": "llama2" }'
{ config, ... }: {
  virtualisation = {
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };
  };
  virtualisation.oci-containers.backend = "podman";
  virtualisation.oci-containers.containers.open-webui = {
    autoStart = true;
    image = "ghcr.io/open-webui/open-webui";
    ports = [ "3000:8080" ];
    # TODO figure out how to create the data directory declaratively
    volumes = [ "${config.users.users.mat.home}/open-webui:/app/backend/data" ];
    extraOptions =
      [ "--network=host" "--add-host=host.containers.internal:host-gateway" ];
    environment = { OLLAMA_API_BASE_URL = "http://127.0.0.1:11434/api"; };
  };
  networking.firewall = { allowedTCPPorts = [ 80 443 8080 11434 3000 ]; };
}
