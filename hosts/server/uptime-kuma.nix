{ pkgs, ... }:
let
  ip = import ./ip.nix;
  disk_usage_script = pkgs.writeShellScriptBin "uptime-kuma-disk-usage-ping" ''
    #!${pkgs.bash}/bin/bash

    disk="/dev/sdc1"

    percentage=$(df -hl --total $disk | tail -1 | ${pkgs.gawk}/bin/awk '{printf $5}')

    threshold="90"

    number=''${percentage%\%*}

    message="Used space on $disk is $number%"

    push_url="http://${ip}:3001/api/push/o4c9CaUnVo"

    echo "threshold: $threshold"
    echo "number:    $number"
    echo "$message"

    if [ ''${number:-0} -lt ''${threshold:-0} ]; then
        service_status="up"
    else
        service_status="down"
    fi

    ${pkgs.curlMinimal}/bin/curl \
        --get \
        --data-urlencode "status=$service_status" \
        --data-urlencode "msg=$message" \
        --data-urlencode "ping=$number" \
        --silent \
        $push_url \
        > /dev/null
  '';
in {
  networking.firewall = {
    allowedTCPPorts = [ 3001 ];
    allowedUDPPorts = [ 3001 ];
  };
  environment.systemPackages = [ disk_usage_script ];
  systemd = {
    timers.uptime-kuma-disk-usage = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "hourly";
        Unit = "uptime-kuma-disk-usage.service";
      };
    };
    services.uptime-kuma-disk-usage.serviceConfig = {
      Type = "oneshot";
      ExecStart = "${disk_usage_script}/bin/uptime-kuma-disk-usage-ping";
    };

  };
  services.uptime-kuma = {
    enable = true;
    appriseSupport = true;
    settings.HOST = ip;
  };
}
