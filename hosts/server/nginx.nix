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
    services = builtins.map (service: {
      name = "${service.name}.mjones.network";
      value = SSL // {
        locations."/" = {
          proxyPass = "http://127.0.0.1:${service.port}";
          extraConfig = ''
            proxy_set_header Host $host;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection $http_connection;
          '';
        };
      };
    }) [
      {
        name = "ai";
        port = "8080";
      }
      {
        name = "jellyfin";
        port = "8096";
      }
      {
        name = "jellyseerr";
        port = "5055";
      }
      {
        name = "homepage";
        port = "8082";
      }
    ];
    virtualHosts = builtins.listToAttrs services;
  in {
    enable = true;
    inherit virtualHosts;
  };
}
