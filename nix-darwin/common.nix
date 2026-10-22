{ pkgs, ... }:
{
  imports = [
    ../nixos/nixpkgs-config.nix
    ../nixos/modules/_1password.nix
    ../nixos/modules/unfree.nix
    (import ../nixos/nix-conf.nix { isHomeManager = false; })
    ./settings.nix
  ];
  nix.optimise.automatic = true;

  dotfiles = {
    _1password.enable = true;
    unfree.packageNames = [
      "1password-cli"
      "claude-code"
      "7zz"
      "discord"
      "discord-unwrapped"
      "parsec-bin"
      "rectangle-pro"
      "spotify"
      "steam"
      "steam-original"
      "steam-run"
      "steam-unwrapped"
    ];
  };
  nixpkgs.hostPlatform = "aarch64-darwin";
  programs.fish.enable = true;
  environment = {
    shells = [ pkgs.fish ];
    variables.HOMEBREW_NO_ANALYTICS = "1";
    systemPath = [ "/opt/homebrew/bin" ];
  };
  security.pam.services.sudo_local.touchIdAuth = true;
  homebrew = {
    enable = true;
    onActivation = {
      cleanup = "zap";
      extraFlags = [ "--force-cleanup" ];
      autoUpdate = true;
      upgrade = true;
    };
    casks = [
      "alfred"
      "ollama-app"
    ];
  };
}
