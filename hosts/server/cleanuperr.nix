{ config, ... }:
let envFile = config.age.secrets.cleanuperr_env.path;
in {
  age.secrets.cleanuperr_env.file = ../../secrets/cleanuperr_env.age;
  virtualisation.oci-containers = {
    backend = "podman";
    containers.cleanuperr = {
      autoStart = true;
      image = "ghcr.io/flmorg/cleanuperr:latest";
      environmentFiles = [ envFile ];
    };
  };
}
