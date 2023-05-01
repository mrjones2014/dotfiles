{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "mat";
  home.homeDirectory = if pkgs.stdenv.isLinux then "/home/mat" else "/Users/mat";

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
    pkgs.neovim
    pkgs.tealdeer
    pkgs.go
    (pkgs.fetchFromGitHub {
      owner = "nix-community";
      repo = "nurl";
      rev = "ca1e2596fdd64de0314aa7c201e5477f0d8c3ab7";
      hash = "sha256-xN6f9XStY3jqEA/nMb7QOnMDBrkhdFRtke0cCQddBRs=";
    })
    # pkgs.op, # no up to date 1Password CLI nix package
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
    DOTNET_CLI_TELEMETRY_OPTOUT = "1";
    HOMEBREW_NO_ANALYTICS = "1";
    CARGO_NET_GIT_FETCH_WITH_CLI = "true";
    GOPATH = "$HOME/go";
    EDITOR = "nvim";
    GIT_MERGE_AUTOEDIT = "no";
    MANPAGER = "nvim -c 'Man!' -o -";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  programs.fish = {
   enable = true;
   plugins = [
    {
       name="foreign-env";
       src = pkgs.fetchFromGitHub {
           owner = "oh-my-fish";
           repo = "plugin-foreign-env";
           rev = "dddd9213272a0ab848d474d0cbde12ad034e65bc";
           sha256 = "00xqlyl3lffc5l0viin1nyp819wf81fncqyz87jx8ljjdhilmgbs";
       };
    }
   ];

   shellAliases = {
    sourcefish = "source ~/.config/fish/config.fish && fish_logo";
    dots = "git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME";
    vim = "nvim";
    vi = "nvim";
    v = "nvim";
    # lol, sometimes I'm stupid
    ":q" = "exit";
    ":Q" = "exit";
    # I swear I'm an idiot sometimes
    ":e" = "nvim";
    update-nvim-plugins = "nvim --headless '+Lazy! sync' +qa";
    cat = "bat";
    gogit = "cd ~/git";
    "!!" = "eval \\$history[1]";
    ls = "exa -a --icons --color=always -s type -F";
    la = "ls -a";
    ll = "ls -l --git";
    l = "ls -laH";
    lg = "ls -lG";
   };

   shellInit = ''
    set -g fish_prompt_pwd_dir_length 20
    set -u fish_greeting ""

    # Setting up SSH_AUTH_SOCK here rather than ~/.ssh/config
    # because that overrides the environment variables,
    # meaning I can't easily switch between the production and
    # debug auth sockets while working on the 1Password desktop app
    set -g -x SSH_TTY (tty)
    if [ "$(uname)" = Darwin ]
        set -g -x SSH_AUTH_SOCK "$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
    else
        set -g -x SSH_AUTH_SOCK "$HOME/.1password/agent.sock"
    end

    # for local-only, non-sync'd stuff
    if test -f $HOME/.config/fish/local.fish
        source $HOME/.config/fish/local.fish
    end
   '';

   interactiveShellInit = ''
    fish_vi_key_bindings
    bind -M insert jk "if commandline -P; commandline -f cancel; else; set fish_bind_mode default; commandline -f backward-char force-repaint; end"

    thefuck --alias | source
    starship init fish | source
    atuin init fish | source
    fnm completions | source
    fnm env | source

    for mode in insert default normal
        bind -M insert \e\[A "_atuin_search; tput cup \$LINES"
        bind -M $mode \a _project_jump
    end

    # I like to keep the prompt at the bottom rather than the top
    # of the terminal window so that running `clear` doesn't make
    # me move my eyes from the bottom back to the top of the screen;
    # keep the prompt consistently at the bottom
    tput cup $LINES
    # this alias doesn't work from Nix `shellAliases` definition because
    # it uses a variable and aliases get single-quotes instead of double-quoted
    alias clear="clear && tput cup \$LINES";
   '';
  };
}
