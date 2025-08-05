let
  port = 11011;
in
{
  services.nginx.subdomains.cleanuparr.port = port;
  virtualisation.oci-containers.containers.cleanuparr = {
    autoStart = true;
    image = "ghcr.io/cleanuparr/cleanuparr:latest";
    ports = [ "${builtins.toString port}:${builtins.toString port}" ];
  };
}
