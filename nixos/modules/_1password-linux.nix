# NixOS-only companion to _1password.nix (see note there).
{ config, lib, ... }:
{
  config = lib.mkIf config.dotfiles._1password.enable {
    programs._1password-gui.polkitPolicyOwners = [ "mat" ];
    environment.etc."1password/custom_allowed_browsers" = {
      text = ''
        zen
      '';
      mode = "0755";
    };
  };
}
