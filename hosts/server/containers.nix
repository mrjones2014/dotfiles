{ pkgs, ... }:
let
  update-containers = pkgs.writeShellScriptBin "update-containers" ''
    	SUDO=""
    	if [[ $(id -u) -ne 0 ]]; then
    		SUDO="sudo"
    	fi

        images=$($SUDO ${pkgs.podman}/bin/podman ps -a --format="{{.Image}}" | sort -u)

        for image in $images
        do
          $SUDO ${pkgs.podman}/bin/podman pull $image
        done
  '';
in
{
  virtualisation = {
    oci-containers.backend = "podman";
    podman = {
      enable = true;
      dockerCompat = true;
      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;
    };
  };
  environment.systemPackages = [ update-containers ];
  # update oci-containers every Monday
  systemd = {
    timers.updatecontainers = {
      timerConfig = {
        Unit = "updatecontainers.service";
        OnCalendar = "Mon 02:00";
      };
      wantedBy = [ "timers.target" ];
    };
    services = {
      updatecontainers = {
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "update-containers";
        };
      };
    };
  };
}
