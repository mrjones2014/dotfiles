{ config, ... }:
let
  port = 30011;
  data_dir = "/var/lib/anythingllm";
in
{
  systemd.tmpfiles.rules = [
    "d ${data_dir} 0750 root root -"
    "f ${data_dir}/.env 0644 root root -"
  ];
  age.secrets.anythingllm_env.file = ../../secrets/anythingllm_env.age;
  virtualisation.oci-containers.containers.anythingllm = {
    image = "mintplexlabs/anythingllm:latest";
    ports = [ "${toString port}:3001" ];
    volumes = [ "${data_dir}:/app/server/storage" ];
    extraOptions = [ "--cap-add=SYS_ADMIN" ];
    environmentFiles = [ config.age.secrets.anythingllm_env.path ];
  };
  services.nginx.subdomains."ai".port = port;
}
