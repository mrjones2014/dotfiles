{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:
{
  home = {
    username = osConfig.users.users.mat.name;
    homeDirectory = osConfig.users.users.mat.home;

    # This value determines the Home Manager release that your configuration is
    # compatible with. This helps avoid breakage when a new Home Manager release
    # introduces backwards incompatible changes.
    #
    # You should not change this value, even if you update Home Manager. If you do
    # want to update the value, then make sure to first check the Home Manager
    # release notes.
    stateVersion = "26.11";
    packages =
      with pkgs;
      [
        spotify
        gnumake
      ]
      ++ lib.lists.optionals pkgs.stdenv.hostPlatform.isDarwin [
        # put macOS specific packages here
        bash # macOS ships with a very old version of bash for whatever reason
        rectangle-pro
      ]
      ++ lib.lists.optionals pkgs.stdenv.hostPlatform.isLinux [
        # put Linux specific packages here
        parsec-bin
        (ungoogled-chromium.override {
          # Crashes on native wayland, use x11 backend
          commandLineArgs = [ "--ozone-platform=x11" ];
        })
        obs-studio
        r2modman
        # sgdboop
      ]
      ++ lib.lists.optionals (!config.dotfiles.work) [
        # just not work machine
        vesktop
        signal-desktop
      ];
  };
  xdg.enable = true;

  imports = [
    ./shared.nix
    ./components/_1password-shell.nix
    ./components/agents
    ./components/gnome
    ./components/terminal.nix
    ./components/vicinae.nix
    ./components/zen.nix
  ];

  programs = {
    nix-index.enable = true;
    # Let Home Manager install and manage itself.
    home-manager.enable = true;
    # Direnv integration for flakes
    direnv = {
      enable = true;
      # TODO remove when the tests are fixed
      package = pkgs.direnv.overrideAttrs { doCheck = false; };
      config.hide_env_diff = true;
      nix-direnv.enable = true;
    };
  };
}
