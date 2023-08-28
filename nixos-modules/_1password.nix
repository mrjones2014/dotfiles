{ pkgs, ... }: {
  programs._1password = { enable = true; };
  programs._1password-gui = {
    package = pkgs._1password-gui-beta;
    enable = true;
    polkitPolicyOwners = [ "mat" ];
  };
}
