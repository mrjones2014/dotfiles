# ensure brew stuff is on PATH
if test -f "/opt/homebrew/bin/brew"
    eval (/opt/homebrew/bin/brew shellenv)
    fish_add_path /opt/homebrew/bin
end

# start tmux session by default
if [ -z "$TMUX" ] && [ "$START_TMUX_PLEASE" = 1 ]
    exec tmux new-session -A -s $USER
end

# workaround for https://github.com/fish-shell/fish-shell/issues/3481
function fish_vi_cursor; end
fish_vi_key_bindings
bind -M insert jk "if commandline -P; commandline -f cancel; else; set fish_bind_mode default; commandline -f backward-char force-repaint; end"

export GPG_TTY=(tty)
export EDITOR="nvim"
export DOTNET_CLI_TELEMETRY_OPTOUT=1

fish_add_path "$HOME/scripts"
fish_add_path "$HOME/.cargo/bin"
fish_add_path "$HOME/.dotnet/tools"

source $HOME/.config/fish/check-globals.fish
source $HOME/.config/fish/fzf-config.fish
source $HOME/.config/fish/aliases.fish
source $HOME/.config/fish/check-architecture.fish

# for local-only, non-sync'd stuff
if test -e $HOME/.config/fish/local.fish
    source $HOME/.config/fish/local.fish
end

thefuck --alias | source
starship init fish | source

###-begin-yaclt-completions-###
#
# yargs command completion script
#
# Installation: yaclt completion-fish >> ~/.config/fish/config.fish
complete --no-files --command yaclt --arguments "(yaclt --get-yargs-completions (commandline -cp))"
