{ pkgs, config, ... }:

{
  home.sessionVariables = {
    DOTNET_CLI_TELEMETRY_OPTOUT = "1";
    HOMEBREW_NO_ANALYTICS = "1";
    CARGO_NET_GIT_FETCH_WITH_CLI = "true";
    GOPATH = "$HOME/go";
    GIT_MERGE_AUTOEDIT = "no";
    NEXT_TELEMETRY_DISABLED = "1";
  };

  home.packages = [
    pkgs.wget
    pkgs.thefuck
    pkgs.gh
    pkgs.fzf
    pkgs.jq
    pkgs.glow
    pkgs.exa
    pkgs.tealdeer
  ];

  # link my fish config
  home.file."${config.xdg.configHome}/fish" = {
    source = ../../fish;
    recursive = true;
  };

  programs.fish = {
    enable = true;

    plugins = [{
      name = "foreign-env";
      src = pkgs.fetchFromGitHub {
        owner = "oh-my-fish";
        repo = "plugin-foreign-env";
        rev = "3ee95536106c11073d6ff466c1681cde31001383";
        hash = "sha256-vyW/X2lLjsieMpP9Wi2bZPjReaZBkqUbkh15zOi8T4Y=";
      };
    }];

    shellAliases = {
      sourcefish = "source ~/.config/fish/config.fish && fish_logo";
      cat = "bat";
      gogit = "cd ~/git";
      "!!" = "eval \\$history[1]";
      ls = "exa -a --icons --color=always -s type -F";
      la = "ls -a";
      ll = "ls -l --git";
      l = "ls -laH";
      lg = "ls -lG";
      nix-apply = if pkgs.stdenv.isDarwin then
        "home-manager switch --flake ~/git/dotfiles/.#mac"
      else
        "sudo nixos-rebuild switch --flake .#pc";
      restart-gui = if pkgs.stdenv.isDarwin then
        "echo 'Not on NixOS'"
      else
        "sudo systemctl restart display-manager.service";
      cfgnix = if pkgs.stdenv.isDarwin then
        "echo 'Not on NixOS'"
      else
        "sudo nvim /etc/nixos/configuration.nix";
    };

    shellInit = ''
      set -g fish_prompt_pwd_dir_length 20

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

      # Source nix files, required to set fish as default shell, otherwise
      # it doesn't have the nix env vars
      if [ -e "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh" ]
        fenv source "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
      end

      fish_add_path "$CARGO_HOME/bin"
    '';

    interactiveShellInit = ''
      fish_vi_key_bindings
      bind -M insert jk "if commandline -P; commandline -f cancel; else; set fish_bind_mode default; commandline -f backward-char force-repaint; end"

      thefuck --alias | source
      starship init fish | source
      atuin init fish | source
      gh completion -s fish | source

      for mode in insert default normal
        bind -M insert \e\[A "_atuin_search; tput cup \$LINES"
        bind -M $mode \a _project_jump
      end

      if [ -e "$XDG_CONFIG_HOME/op/plugins.sh" ]
        source "$XDG_CONFIG_HOME/op/plugins.sh"
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

    functions = { fish_greeting = ""; };
  };
}
