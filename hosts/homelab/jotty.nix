let
  port = 65531;
  state_dir = "/var/lib/jotty";
in
{
  services.nginx.subdomains.jotty.port = port;
  systemd.tmpfiles.rules = [
    "d ${state_dir} 0755 1000 1000 - -"
    "d ${state_dir}/data 0755 1000 1000 - -"
    "d ${state_dir}/config 0755 1000 1000 - -"
    "d ${state_dir}/cache 0755 1000 1000 - -"
  ];
  virtualisation.oci-containers.containers.jotty = {
    image = "ghcr.io/fccview/jotty:latest";
    user = "1000:1000";
    ports = [ "${toString port}:3000" ];
    volumes = [
      "${state_dir}/data:/app/data:rw"
      "${state_dir}/config:/app/config:rw"
      "${state_dir}/cache:/app/cache:rw"
    ];
    environment.NODE_ENV = "production";
  };
}
