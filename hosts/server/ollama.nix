{ pkgs, ... }: {
  imports = [ ./open-webui.nix ];
  services.ollama.enable = true;
  environment.systemPackages = [ pkgs.oterm ];
}
