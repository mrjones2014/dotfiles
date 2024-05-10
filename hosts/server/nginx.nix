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
        name = "deluge";
        port = "8112";
      }
      {
        name = "prowlarr";
        port = "9696";
      }
      {
        name = "sonarr";
        port = "8989";
      }
      {
        name = "radarr";
        port = "7878";
      }
      {
        name = "jellyseerr";
        port = "5055";
      }
    ];
    virtualHosts = builtins.listToAttrs services;
  in {
    enable = true;
    inherit virtualHosts;
  };
}
