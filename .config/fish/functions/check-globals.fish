function check-globals --description "Check for missing command line tools and print instructions on how to install them"
    if test -z "$(ls ~/Library/Fonts | grep DankMono || echo '')"
        echo "Install DankMono font: Download link stored in 1Password under 'DankMono Font'"
    end

    if test -z "$(ls ~/Library/Fonts | grep JetBrains || echo '')"
        echo "Install Jetbrains Mono NerdFont: brew tap homebrew/cask-fonts && brew install --cask font-jetbrains-mono-nerd-font"
    end

    if ! type delta &>/dev/null
        echo "Install delta and configure it as git's default diff handler: brew install git-delta, then see: https://github.com/dandavison/delta#get-started"
    end

    if ! type thefuck &>/dev/null
        echo "Install thefuck: brew install thefuck"
    end

    if ! type vifi &>/dev/null
        echo "Install vifi-prompt: cargo install vifi-prompt"
    end

    if ! type nvim &>/dev/null
        echo "Install neovim: brew install neovim"
    end

    if ! type fzf &>/dev/null
        echo "Install fzf: brew install fzf"
    end

    if ! type rg &>/dev/null
        echo "Install RipGrep: brew install ripgrep"
    end

    if ! type node &>/dev/null
        echo "Install node.js: brew install node"
    end

    if ! type pnpm &>/dev/null
        echo "Install pnpm: brew install pnpm"
    end

    if ! type eslint_d &>/dev/null
        echo "Install eslint_d globally for Neovim integration: pnpm i -g eslint_d"
    end

    if ! type prettierd &>/dev/null
        echo "Install prettierd globally for Neovim integration: pnpm i -g @fsouza/prettierd"
    end

    if ! type typescript-language-server &>/dev/null
        echo "Install tsserver globally for Neovim integration: pnpm i -g typescript typescript-language-server"
    end

    if ! type vscode-css-language-server &>/dev/null
        echo "Install CSS language server globally for Neovim integration: pnpm i -g vscode-langservers-extracted"
    end

    if ! type svelteserver &>/dev/null
        echo "Install svelte-language-server globally for Neovim integration: pnpm i -g svelte-language-server"
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

    if ! type cargo-sweep &>/dev/null
        echo "Install cargo-sweep: cargo install cargo-sweep"
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

    if ! type gopls &>/dev/null
        echo "Install gopls: brew install gopls"
    end

    if ! type lua-language-server &>/dev/null
        echo "Install lua-language-server: brew install lua-language-server"
    end

    if ! type teal-language-server &>/dev/null
        echo 'Install teal-language-server: luarocks install --dev teal-language-server'
    end

    if ! type op &>/dev/null
        echo "Install 1Password CLI: brew install --cask 1password/tap/1password-cli"
    end

    if test ! -d /Applications/Hammerspoon.app
        echo "Install Hammerspoon: https://github.com/Hammerspoon/hammerspoon/releases/latest, then run `defaults write org.hammerspoon.Hammerspoon MJConfigFile '~/.config/hammerspoon/init.lua'`"
    end

    if test ! -d /Applications/kindaVim.app
        echo "Install KindaVim: https://kindavim.app, license is in 1Password"
    end

    if test ! -d /Applications/LibreWolf.app
        echo "Install LibreWolf browser: brew install --cask librewolf && xattr -d com.apple.quarantine /Applications/LibreWolf.app"
    end

    if test ! -d "/Applications/Alfred 4.app"
        echo "Install Raycast: brew install alfred"
    end

    if ! type tmux &>/dev/null
        echo "Install tmux: brew install --HEAD tmux"
    end

    if [ ! -d "$HOME/.tmux/plugins/tpm" ]
        echo "Install tmux plugin manager: https://github.com/tmux-plugins/tpm"
    end

    return 0
end
