{
  pkgs,
  lib,
  isDarwin,
  isLinux,
  isThinkpad,
  isWorkMac,
  ...
}:
let
  username = if isWorkMac then "mat.jones" else "mat"; # username is set by MDM on work machine :/
  homePrefix = if isLinux then "/home" else "/Users";
in
{
  home = {
    inherit username;
    homeDirectory = "${homePrefix}/${username}";

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
        parsec-bin
        (ungoogled-chromium.override {
          # Crashes on native wayland, use x11 backend
          commandLineArgs = [ "--ozone-platform=x11" ];
        })
        (discord.override {
          withOpenASAR = true;
          withVencord = true;
        })
      ]
      ++ lib.lists.optionals isThinkpad [ ]
      ++ lib.lists.optionals (isLinux && (!isThinkpad)) [
        # desktop only packages
        obs-studio
        r2modman
        # sgdboop
      ];
  };
  xdg.enable = true;

  imports = [
    ./shared.nix
    ./components/_1password-shell.nix
    ./components/gnome
    ./components/opencode.nix
    ./components/recyclarr.nix
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
      config.hide_env_diff = true;
      nix-direnv.enable = true;
    };
  };
}
