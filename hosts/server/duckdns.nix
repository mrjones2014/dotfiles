{ config, ... }: {
  age.secrets.duckdns_token.file = ../../secrets/duckdns_token.age;
  services.duckdns = {
    enable = true;
    tokenFile = config.age.secrets.duckdns_token.path;
    domains = [ "mjonesnetwork" ];
  };
}
