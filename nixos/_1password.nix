{ isLinux, lib, ... }:
{
  programs._1password.enable = true;
  programs._1password-gui.enable = true;
}
// lib.optionalAttrs isLinux {
  programs._1password-gui.polkitPolicyOwners = [ "mat" ];
  environment.etc."1password/custom_allowed_browsers" = {
    text = ''
      zen
    '';
    mode = "0755";
  };
}
