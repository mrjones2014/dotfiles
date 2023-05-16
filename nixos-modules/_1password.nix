# requires:
# sudo nix-channel --add https://nixos.org/channels/nixos-unstable nixos-unstable
# sudo nix-channel --update
let unstable = import <nixos-unstable> { config = { allowUnfree = true; }; };
in {
  programs._1password = {
    package = unstable._1password;
    enable = true;
  };
  programs._1password-gui = {
    package = unstable._1password-gui;
    enable = true;
    polkitPolicyOwners = [ "mat" ];
  };
}
