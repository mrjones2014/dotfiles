{ pkgs, ... }:
let
  podman_dns_port = 8053;
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

        # restart all running containers
        $SUDO ${pkgs.podman}/bin/podman container restart --running
  '';
in
{
  virtualisation = {
    oci-containers.backend = "podman";
    podman.defaultNetwork.settings.dns_enabled = true;
    containers.containersConf.settings.network.dns_bind_port = podman_dns_port;
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
          # prevents service from running every time I nixos-rebuild: https://wiki.nixos.org/wiki/Systemd/timers
          RemainAfterExit = true;
        };
      };
    };
  };
}
