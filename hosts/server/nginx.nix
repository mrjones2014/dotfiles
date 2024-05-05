{
  networking.firewall.allowedTCPPorts = [ 80 443 ];
  security.acme = {
    acceptTerms = true;
    defaults.email = "homelab@mjones.network";
  };
  services.nginx = let
    SSL = {
      enableACME = true;
      forceSSL = true;
    };
  in {
    enable = true;
    virtualHosts = {
      "ai.mjones.network" = SSL // {
        locations."/".proxyPass = "http://127.0.0.1:8080";
      };
      "jellyfin.mjones.network" = SSL // {
        locations."/".proxyPass = "http://127.0.0.1:8096";
      };
    };
  };
}
