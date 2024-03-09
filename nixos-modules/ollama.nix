{ pkgs, ... }: {
  imports = [ ./open-webui.nix ];
  services.ollama = {
    enable = true;
    acceleration = "cuda";
  };
  environment.systemPackages = [ pkgs.oterm ];
}
