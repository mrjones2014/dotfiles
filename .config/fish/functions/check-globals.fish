function check-globals --description "Check for missing command line tools and print instructions on how to install them"
    if test -z "$(ls ~/Library/Fonts | grep DankMono || echo '')"
        echo "Install DankMono font: Download link stored in 1Password under 'DankMono Font'"
    end

    if test -z "$(ls ~/Library/Fonts | grep JetBrains || echo '')"
        echo "Install Jetbrains Mono NerdFont: brew tap homebrew/cask-fonts && brew install --cask font-jetbrains-mono-nerd-font"
    end

    if ! type diff-so-fancy &>/dev/null
        echo "Install diff-so-fancy and configure it as git's default diff handler: brew install diff-so-fancy, then see: https://github.com/so-fancy/diff-so-fancy#usage"
    end

    if ! type thefuck &>/dev/null
        echo "Install thefuck: https://github.com/nvbn/thefuck"
    end

    if ! type starship &>/dev/null
        echo "Install starship: https://github.com/starship/starship"
    end

    if ! type fisher &>/dev/null
        echo "Install fisher: https://github.com/jorgebucaran/fisher"
    end

    if ! fisher list | grep nvm.fish &>/dev/null
        echo "Install nvim.fish: fisher install jorgebucaran/nvm.fish"
    end

    if ! type nvim &>/dev/null
        echo "Install neovim: https://github.com/neovim/neovim"
    end

    if ! type fzf &>/dev/null
        echo "Install fzf: https://github.com/junegunn/fzf"
    end

    if ! type rg &>/dev/null
        echo "Install RipGrep: https://github.com/BurntSushi/ripgrep"
    end

    if ! type nvm &>/dev/null
        echo "Install nvm.fish: https://github.com/jorgebucaran/nvm.fish"
    end

    if ! type node &>/dev/null
        echo "Install node.js via nvm"
    end

    if ! type eslint_d &>/dev/null
        echo "Install eslint_d globally for Neovim integration: npm i -g eslint_d"
    end

    if ! type prettierd &>/dev/null
        echo "Install prettierd globally for Neovim integration: npm i -g @fsouza/prettierd"
    end

    if ! type typescript-language-server &>/dev/null
        echo "Install tsserver globally for Neovim integration: npm i -g typescript typescript-language-server"
    end

    if ! type vscode-css-language-server &>/dev/null
        echo "Install CSS language server globally for Neovim integration: npm i -g vscode-langservers-extracted"
    end

    if ! type svelteserver &>/dev/null
        echo "Install svelte-language-server globally for Neovim integration: npm i -g svelte-language-server"
    end

    if ! type cargo &>/dev/null
        echo "Install rustup: curl --proto \"=https\" --tlsv1.2 -sSf https://sh.rustup.rs | sh"
    end

    if ! type atuin &>/dev/null
        echo "Install atuin: cargo install atuin"
    end

    if ! type ctrlg &>/dev/null
        echo "Install ctrlg: cargo install ctrlg"
    end

    if ! type stylua &>/dev/null
        echo "Install stylua: cargo install stylua --features lua52"
    end

    if ! type shellcheck &>/dev/null
        echo 'Install shellcheck: brew install shellcheck'
    end

    if ! type shfmt &>/dev/null
        echo 'Install shfmt: brew install shfmt'
    end

    if ! type dotnet &>/dev/null
        echo 'Install dotnet: https://dotnet.microsoft.com/download/dotnet/5.0'
    end

    if ! type csharp-ls &>/dev/null
        echo 'Install csharp-ls: dotnet tool install --global csharp-ls'
    end

    if ! type bat &>/dev/null
        echo "Install bat: brew install bat"
    end

    if ! type exa &>/dev/null
        echo "Install exa: brew install exa"
    end

    if ! type codespell &>/dev/null
        echo "Install codespell: brew install codespell"
    end

    if ! type luacheck &>/dev/null
        echo 'Install luacheck: luarocks install luacheck'
    end

    if ! type rust-analyzer &>/dev/null
        echo "Install rust-analyzer: brew install rust-analyzer"
    end

    if ! type lua-language-server &>/dev/null
        echo "Install lua-language-server: brew install lua-language-server"
    end

    if ! type op &>/dev/null
        echo "Install 1Password CLI: brew install --cask 1password/tap/1password-cli"
    end

    if test ! -d /Applications/Hammerspoon.app
        echo "Install Hammerspoon: https://github.com/Hammerspoon/hammerspoon/releases/latest"
    end

    if test ! -d ~/.hammerspoon/Spoons/VimMode.spoon
        echo "Install VimMode.spoon for Hammerspoon: mkdir -p ~/.hammerspoon/Spoons && git clone https://github.com/dbalatero/VimMode.spoon ~/.hammerspoon/Spoons/VimMode.spoon"
    end

    if test ! -d /Applications/LibreWolf.app
        echo "Install LibreWolf browser: brew install --cask librewolf && xattr -d com.apple.quarantine /Applications/LibreWolf.app"
    end

    if [ ! -d "$HOME/.tmux/plugins/tpm" ]
        echo "Install tmux plugin manager: https://github.com/tmux-plugins/tpm"
    end

    return 0
end
