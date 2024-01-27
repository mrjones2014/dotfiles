{ inputs, pkgs, ... }: {
  nixpkgs.overlays = [
    (final: prev:
      (import ../packages {
        inherit inputs;
        inherit pkgs;
      }))
  ];
  home = {
    username = "mat";
    homeDirectory = "/home/mat";
    # This value determines the Home Manager release that your configuration is
    # compatible with. This helps avoid breakage when a new Home Manager release
    # introduces backwards incompatible changes.
    #
    # You should not change this value, even if you update Home Manager. If you do
    # want to update the value, then make sure to first check the Home Manager
    # release notes.
    stateVersion = "22.11";
  };
  xdg.enable = true;
  xdg.configFile."nix/nix.conf".text = ''
    experimental-features = nix-command flakes
    # see https://github.com/nix-community/nix-direnv#via-home-manager
    keep-derivations = true
    keep-outputs = true
  '';
  imports = [
    ./modules/fish.nix
    ./modules/nvim.nix
    ./modules/ssh.nix
    ./modules/starship.nix
    ./modules/git.nix
    ./modules/fzf.nix
    ./modules/bat.nix
  ];
}
