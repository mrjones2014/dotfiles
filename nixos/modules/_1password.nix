# Cross-system (NixOS + nix-darwin) 1Password module.
# Linux-only pieces live in _1password-linux.nix, which only the NixOS
# aggregator imports, the options it sets don't exist on nix-darwin.
{ config, lib, ... }:
let
  cfg = config.dotfiles._1password;
in
{
  options.dotfiles._1password.enable = lib.mkEnableOption "1Password GUI + CLI";

  config = lib.mkIf cfg.enable {
    dotfiles.unfree.packageNames = [ "1password" ];
    programs._1password.enable = true;
    programs._1password-gui.enable = true;
  };
}
