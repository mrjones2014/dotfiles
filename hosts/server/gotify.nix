{
  services.gotify = {
    enable = true;
    environment.GOTIFY_SERVER_PORT = "9999";
  };
  networking.firewall = {
    allowedTCPPorts = [ 9999 ];
    allowedUDPPorts = [ 9999 ];
  };
}
