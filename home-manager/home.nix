{
  inputs,
  config,
  pkgs,
  lib,
  isDarwin,
  isLinux,
  isThinkpad,
  ...
}:
{
  nixpkgs.overlays = [
    (
      final: prev:
      (import ../packages {
        inherit inputs;
        inherit pkgs;
        inherit (prev) system;
      })
    )
  ];
  home = {
    username = "mat";
    homeDirectory = if isLinux then "/home/mat" else "/Users/mat";

    # This value determines the Home Manager release that your configuration is
    # compatible with. This helps avoid breakage when a new Home Manager release
    # introduces backwards incompatible changes.
    #
    # You should not change this value, even if you update Home Manager. If you do
    # want to update the value, then make sure to first check the Home Manager
    # release notes.
    stateVersion = "22.11";
    packages =
      with pkgs;
      [
        spotify
        gnumake
      ]
      ++ lib.lists.optionals isDarwin [
        # put macOS specific packages here
        bash # macOS ships with a very old version of bash for whatever reason
      ]
      ++ lib.lists.optionals isLinux [
        # put Linux specific packages here
        signal-desktop
        vlc
        parsec-bin
        ungoogled-chromium
      ]
      ++ lib.lists.optionals isThinkpad [ ]
      ++ lib.lists.optionals (isLinux && (!isThinkpad)) [
        # desktop only packages
        obs-studio
        r2modman
        openrct2
      ];
    file."${config.home.homeDirectory}/.xprofile".text = ''
      export XDG_DATA_DIRS="$XDG_DATA_DIRS:/home/mat/.nix-profile/share"
    '';
  };
  xdg.enable = true;

  imports = [
    ./shared.nix
    ./components/terminal.nix
    ./components/_1password-shell.nix
    ./components/espanso.nix
    ./components/gnome
    ./components/recyclarr.nix
    ./components/jujutsu.nix
    ./components/vencord.nix
    ../nixos/allowed-unfree.nix
    inputs.zen-browser.homeModules.default
  ];

  programs = {
    zen-browser.enable = !isDarwin;
    nix-index.enable = true;
    # Let Home Manager install and manage itself.
    home-manager.enable = true;
    # Direnv integration for flakes
    direnv = {
      enable = true;
      config.hide_env_diff = true;
      nix-direnv.enable = true;
    };
  };
}
