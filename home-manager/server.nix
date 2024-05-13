{ inputs, pkgs, ... }: {
  nixpkgs.overlays = [
    (final: prev:
      (import ../packages {
        inherit inputs;
        inherit pkgs;
      }))
    inputs.neovim-nightly-overlay.overlay
  ];
  home = {
    username = "mat";
    homeDirectory = "/home/mat";
    sessionVariables = {
      TERM = "xterm-256color";
      COLORTERM = "truecolor";
    };
    # While we aren't in a graphical environment on the server,
    # having the `wezterm` CLI available allows us to use the nice
    # `wezterm connect` command for an enhanced SSH experience
    packages = [ pkgs.wezterm ];
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
  imports = [ ./shared.nix ];
}
