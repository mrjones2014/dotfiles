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

    if ! type gh &>/dev/null
        echo "Install GitHub CLI: brew install gh"
    end

    if ! type thefuck &>/dev/null
        echo "Install thefuck: brew install thefuck"
    end

    if ! type starship &>/dev/null
        echo "Install starship: cargo install starship"
    end

    if ! type wget &>/dev/null
        echo "Install wget: brew install wget"
    end

    if ! type topgrade &>/dev/null
        echo "Install topgrade: brew install topgrade"
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

    if ! type jq &>/dev/null
        echo "Install jq: brew install jq"
    end

    if ! type cargo &>/dev/null
        echo "Install rustup: curl --proto \"=https\" --tlsv1.2 -sSf https://sh.rustup.rs | sh"
    end

    if test -z "$(ls ~/.cargo/bin/ | grep cargo-nextest || echo '')"
        echo "Install cargo-nextest: curl -LsSf https://get.nexte.st/latest/mac | tar zxf - -C ~/.cargo/bin"
    end

    if test -z "$(ls ~/.cargo/bin/ | grep cargo-install-update || echo '')"
        echo "Install cargo-update: cargo install cargo-update --features vendored-openssl"
    end

    if ! type atuin &>/dev/null
        echo "Install atuin: cargo install atuin"
    end

    if ! type ctrlg &>/dev/null
        echo "Install ctrlg: cargo install ctrlg"
    end

    if ! type bat &>/dev/null
        echo "Install bat: brew install bat"
    end

    if ! type exa &>/dev/null
        echo "Install exa: brew install exa"
    end

    if ! type op &>/dev/null
        echo "Install 1Password CLI: brew install --cask 1password/tap/1password-cli"
    end

    if test ! -d /Applications/Hammerspoon.app
        echo "Install Hammerspoon: brew install hammerspoon, then run `defaults write org.hammerspoon.Hammerspoon MJConfigFile '~/.config/hammerspoon/init.lua'`"
    end

    if test ! -d "/Applications/CleanShot X.app"
        echo "Install Cleanshot X: info in 1Password"
    end

    if test ! -d /Applications/kindaVim.app
        echo "Install KindaVim: https://kindavim.app, license is in 1Password"
    end

    if test ! -d /Applications/LibreWolf.app
        echo "Install LibreWolf browser: brew install --cask librewolf && xattr -d com.apple.quarantine /Applications/LibreWolf.app"
    end

    if test ! -d "/Applications/Raycast.app"
        echo "Install Raycast: brew install raycast"
    end

    if ! type tmux &>/dev/null
        echo "Install tmux: brew install --HEAD tmux"
    end

    if ! type gh &>/dev/null
        echo "Install GitHub CLI: brew install gh"
    end

    return 0
end
