{ config, ... }:
{
  imports = [ ./nixosModules/silverbullet.nix ];
  age.secrets = {
    silverbullet_env.file = ../../secrets/silverbullet_env.age;
    silverbullet_shared_env.file = ../../secrets/silverbullet_shared_env.age;
  };
  services.silverbullet.instances = {
    main = {
      enable = true;
      subdomain = "sb";
      port = 9632;
      environmentFiles = [ config.age.secrets.silverbullet_env.path ];
    };
    shared = {
      enable = true;
      subdomain = "house";
      port = 9633;
      environmentFiles = [ config.age.secrets.silverbullet_shared_env.path ];
    };
  };
}
