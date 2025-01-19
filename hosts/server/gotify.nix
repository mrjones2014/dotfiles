let port = 9898;
in {
  services.gotify = {
    enable = true;
    environment.GOTIFY_SERVER_PORT = builtins.toString port;
  };
  networking.firewall = {
    allowedTCPPorts = [ port ];
    allowedUDPPorts = [ port ];
  };
}
