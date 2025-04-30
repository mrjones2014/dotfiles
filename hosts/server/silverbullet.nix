{ config, ... }:
{
  imports = [ ./nixosModules/silverbullet.nix ];
  age.secrets.silverbullet_env.file = ../../secrets/silverbullet_env.age;
  services.silverbullet.instances = {
    main = {
      enable = true;
      subdomain = "sb";
      port = 9632;
      environmentFiles = [ config.age.secrets.silverbullet_env.path ];
    };
    # shared = {
    #   enable = true;
    #   subdomain = "house.mjones.network";
    #   port = 9633;
    # };
  };
}
