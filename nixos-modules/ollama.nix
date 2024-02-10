{ pkgs, ... }: {
  imports = [ ./ollama-webui.nix ];
  services.ollama.enable = true;
  environment.systemPackages = [ pkgs.oterm ];
}

