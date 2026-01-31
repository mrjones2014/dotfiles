{ config, ... }:
let
  port = 30011;
  data_dir = "/var/lib/anythingllm";
in
{
  users = {
    users.anythingllm = {
      isSystemUser = true;
      group = "anythingllm";
    };
    groups.anythingllm = { };
  };
  systemd.tmpfiles.rules = [
    "d ${data_dir} 0750 anythingllm anythingllm -"
  ];
  age.secrets.anythingllm_env = {
    file = ../../secrets/anythingllm_env.age;
    owner = "anythingllm";
    group = "anythingllm";
  };
  virtualisation.oci-containers.containers.anythingllm = {
    image = "mintplexlabs/anythingllm:latest";
    ports = [ "${toString port}:3001" ];
    volumes = [ "${data_dir}:/app/server/storage" ];
    extraOptions = [ "--cap-add=SYS_ADMIN" ];
    user = "${toString config.users.users.anythingllm.uid}:${toString config.users.groups.anythingllm.gid}";
    environmentFiles = [ config.age.secrets.anythingllm_env.path ];
    environment = {
      UID = toString config.users.users.anythingllm.uid;
      GID = toString config.users.groups.anythingllm.gid;
    };
  };
  services.nginx.subdomains."ai".port = port;
}
