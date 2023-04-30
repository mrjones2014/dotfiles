{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "mat";
  home.homeDirectory = "/home/mat";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "22.11"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
    (pkgs.nerdfonts.override { fonts = ["FiraCode"]; })
    pkgs.catimg
    pkgs.delta
    pkgs.gh
    pkgs.thefuck
    pkgs.starship
    pkgs.wget
    pkgs.topgrade
    pkgs.fzf
    pkgs.ripgrep
    pkgs.fnm
    pkgs.jq
    pkgs.rustup
    pkgs.cargo-nextest
    pkgs.atuin
    pkgs.cargo-update
    pkgs.bat
    pkgs.glow
    pkgs.exa
    pkgs.librewolf
    # pkgs.op, # no up to date 1Password CLI nix package
    # pkgs.bob # no bob-nvim nix package
    #pkgs.hammerspoon, no package
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
    "${config.xdg.configHome}" = { source = ~/git/dotfiles/.config; recursive = true; };
    ".ssh/config".source = ~/git/dotfiles/.ssh/config;
  };

  # You can also manage environment variables but you will have to manually
  # source
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/mat/etc/profile.d/hm-session-vars.sh
  #
  # if you don't want to manage your shell through Home Manager.
  home.sessionVariables = {
    # EDITOR = "emacs";
    DOTNET_CLI_TELEMETRY_OPTOUT = "1";
    HOMEBREW_NO_ANALYTICS = "1";
    CARGO_NET_GIT_FETCH_WITH_CLI = "true";
    GOPATH = "$HOME/go";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  programs.fish = {
   enable = true;

   plugins = [{
       name="foreign-env";
       src = pkgs.fetchFromGitHub {
           owner = "oh-my-fish";
           repo = "plugin-foreign-env";
           rev = "dddd9213272a0ab848d474d0cbde12ad034e65bc";
           sha256 = "00xqlyl3lffc5l0viin1nyp819wf81fncqyz87jx8ljjdhilmgbs";
       };
   }];
  };
}

