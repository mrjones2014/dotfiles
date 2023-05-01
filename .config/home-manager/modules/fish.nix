{ pkgs, ... }:

{
    home.sessionVariables = {
        DOTNET_CLI_TELEMETRY_OPTOUT = "1";
        HOMEBREW_NO_ANALYTICS = "1";
        CARGO_NET_GIT_FETCH_WITH_CLI = "true";
        GOPATH = "$HOME/go";
        EDITOR = "nvim";
        GIT_MERGE_AUTOEDIT = "no";
        MANPAGER = "nvim -c 'Man!' -o -";
    };

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

    # Setting up SSH_AUTH_SOCK here rather than ~/.ssh/config
    # because that overrides the environment variables,
    # meaning I can't easily switch between the production and
    # debug auth sockets while working on the 1Password desktop app
    set -g -x SSH_TTY (tty)
    if [ "$(uname)" = Darwin ]
        fish_add_path /Applications/WezTerm.app/Contents/MacOS/
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

   functions = {
    fish_greeting = "";
   };
  };
}
