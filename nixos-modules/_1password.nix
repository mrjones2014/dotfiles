{ pkgs, ... }: {
  programs._1password = {
    enable = true;
    # package = pkgs.unstable._1password;
  };
  programs._1password-gui = {
    enable = true;
    # package = pkgs.unstable._1password-gui;
    polkitPolicyOwners = [ "mat" ];
  };
}
