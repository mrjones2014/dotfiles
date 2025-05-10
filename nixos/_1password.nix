{
  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "mat" ];
  };
  environment.etc."1password/custom_allowed_browsers" = {
    text = ''
      .zen-wrapped
    '';
    mode = "0755";
  };
}
