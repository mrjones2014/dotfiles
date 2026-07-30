# based on https://github.com/eh8/chenglab/blob/6cafec44a07459cf2b666f8a3ff5f34773348bc1/services/scrypted.nix
let
  port = 11080;
in
{
  # Homekit requires random port to connect with accessories. It is easier to
  # whitelist an entire trusted network rather than tediously open ports for
  # each camera.
  networking.firewall.trustedInterfaces = [ "enp0s31f6" ];

  virtualisation.oci-containers.containers."scrypted" = {
    image = "ghcr.io/koush/scrypted";
    # its behind reverse proxy so this is fine
    environment.SCRYPTED_INSECURE_PORT = toString port;
    volumes = [
      "/var/lib/scrypted:/server/volume:rw"
    ];
    extraOptions = [
      "--log-opt=max-file=10"
      "--log-opt=max-size=10m"
      "--network=host"
      # GPU passthru in case I wanna do NVR
      # directly on Scrypted in the future
      "--device=/dev/dri:/dev/dri"
    ];
  };

  services.nginx.subdomains.scrypted.port = port;
  systemd.tmpfiles.rules = [ "d /var/lib/scrypted 0755 root root" ];
}
