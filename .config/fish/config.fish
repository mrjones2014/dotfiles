export GPG_TTY=(tty)

if ! type thefuck >/dev/null
    echo 'Install thefuck: https://github.com/nvbn/thefuck'
else
    thefuck --alias | source
end

if ! type omf >/dev/null
    echo 'Install oh-my-fish: https://github.com/oh-my-fish/oh-my-fish'
end

if ! type fisher >/dev/null
    echo 'Install fisher: https://github.com/jorgebucaran/fisher'
end

if ! type nvim >/dev/null
    echo 'Install neovim: https://github.com/neovim/neovim'
end

if ! type fzf >/dev/null
    echo 'Install fzf: https://github.com/junegunn/fzf'
end

if ! type fd >/dev/null
    echo 'Install the Silver Searcher: https://github.com/ggreer/the_silver_searcher'
end

set FZF_DEFAULT_COMMAND 'ag --hidden --ignore .git -g ""'

set PATH $PATH "$HOME/scripts"

source $HOME/.config/fish/aliases.fish

if ! type starship >/dev/null
    echo 'Install starship: https://github.com/starship/starship'
else
    # MUST BE LAST LINE
    starship init fish | source
end
