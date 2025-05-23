{ config, ... }:
{
  services.nginx.subdomains.vikunja.port = config.services.vikunja.port;
  services.vikunja = {
    enable = true;
    frontendScheme = "http";
    frontendHostname = import ./ip.nix;
  };
}
