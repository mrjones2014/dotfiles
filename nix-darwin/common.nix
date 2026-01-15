{ pkgs, ... }:
{
  imports = [
    ../nixos/nixpkgs-config.nix
    ../nixos/_1password.nix
    (import ../nixos/nix-conf.nix { isHomeManager = false; })
    ./settings.nix
  ];
  nix.optimise.automatic = true;
  nixpkgs.hostPlatform = "aarch64-darwin";
  programs.fish.enable = true;
  environment = {
    shells = [ pkgs.fish ];
    variables.HOMEBREW_NO_ANALYTICS = "1";
    systemPath = [ "/opt/homebrew/bin" ];
  };
  programs._1password.enable = true;
  homebrew = {
    enable = true;
    onActivation = {
      cleanup = "zap";
      autoUpdate = true;
      upgrade = true;
    };
    casks = [
      "ghostty"
      "zen"
      "alfred"
      "spotify"
      "home-assistant"
    ];
  };
}
