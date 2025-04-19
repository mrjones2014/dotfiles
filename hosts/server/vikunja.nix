{ config, ... }: {
  networking.firewall = {
    allowedTCPPorts = [ config.services.vikunja.port ];
    allowedUDPPorts = [ config.services.vikunja.port ];
  };
  services.nginx.subdomains.vikunja = 3456;
  services.vikunja = {
    enable = true;
    frontendScheme = "http";
    frontendHostname = import ./ip.nix;
  };
}
