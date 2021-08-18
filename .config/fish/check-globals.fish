function check_globals
    if test -z "(ls ~/Library/Fonts | grep 'Fira Code')"
        echo 'Install Fira Code NerdFont: https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts/FiraCode'
    end

    if test -z "(ls ~/Library/Fonts | grep nonicons)"
        echo 'Install nonicons font: https://github.com/yamatsum/nonicons'
    end

    if ! type thefuck &> /dev/null
        echo 'Install thefuck: https://github.com/nvbn/thefuck'
    end

    if ! type starship &> /dev/null
        echo 'Install starship: https://github.com/starship/starship'
    end

    if ! type omf &> /dev/null
        echo 'Install oh-my-fish: https://github.com/oh-my-fish/oh-my-fish'
    end

    if ! type fisher &> /dev/null
        echo 'Install fisher: https://github.com/jorgebucaran/fisher'
    end

    if ! type nvim &> /dev/null
        echo 'Install neovim: https://github.com/neovim/neovim'
    end

    if ! type fzf &> /dev/null
        echo 'Install fzf: https://github.com/junegunn/fzf'
    end

    if ! type ag &> /dev/null
        echo 'Install the Silver Searcher: https://github.com/ggreer/the_silver_searcher'
    end

    if ! type rg &> /dev/null
        echo 'Install RipGrep: https://github.com/BurntSushi/ripgrep'
    end

    if ! type nvm &> /dev/null
        echo 'Install nvm.fish: https://github.com/jorgebucaran/nvm.fish'
    end

    if ! type node &> /dev/null
        echo 'Install node.js via nvm'
    end

    if ! type yarn &> /dev/null
        echo 'Install yarn: npm i -g yarn'
    end

    if ! type eslint_d &> /dev/null
        echo 'Install eslint globally for Neovim integration: yarn global add eslint_d'
    end

    if ! type typescript-language-server &> /dev/null
        echo 'Install tsserver globally for vim integration: yarn global add typescript typescript-language-server'
    end

    if ! type vscode-css-language-server &> /dev/null
        echo 'Install tsserver globally for vim integration: yarn global add vscode-langservers-extracted'
    end

    if ! type diagnostic-languageserver &> /dev/null
        echo 'Install diagnostic-languageserver: yarn global add diagnostic-languageserver'
    end


    if ! type bash-language-server &> /dev/null
        echo 'Install bash-language-server: yarn global add bash-language-server'
    end

    if ! type neovim-node-host &> /dev/null
        echo 'Install neovim helper: yarn global add neovim'
    end

    if ! type cargo &> /dev/null
        echo 'Install rustup: curl --proto \'=https\' --tlsv1.2 -sSf https://sh.rustup.rs | sh'
    end

    if ! type rustup &> /dev/null
        echo 'Install rustup fish plugin: omf install rustup'
    end

    if ! type bat &> /dev/null
        echo 'Install bat: brew install bat'
    end

    if ! type exa &> /dev/null
        echo 'Install exa: brew install exa'
    end

    if ! type stylua &> /dev/null
        echo 'Install stylua: cargo install stylua --features lua52'
    end

    if [ -z (pip3 list | grep -F pynvim) ]
        echo "Install pynvim: pip3 install pynvim"
    end

    if [ -z (ls /Applications/ | grep -i hammerspoon) ]
        echo "Install Hammerspoon: https://github.com/Hammerspoon/hammerspoon/releases/latest"
    end

    #  ~/.tmux/plugins/tpm
    if [ ! -d "$HOME/.tmux/plugins/tpm" ]
        echo "Install tmux plugin manager: https://github.com/tmux-plugins/tpm"
    end

    if [ ! -d "$HOME/.local/share/nvim/site/pack/packer/start" ]
        echo "Install vim packer: https://github.com/wbthomason/packer.nvim#quickstart"
    end

    return 0
end
