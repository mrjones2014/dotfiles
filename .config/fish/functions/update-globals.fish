function update-globals --description "Update brew packages, some cargo packages, and npm global packages"
    # update cargo packages
    cargo install --force atuin
    cargo install --force caniuse-rs
    cargo install --force mdbook
    cargo install --force stylua
    cargo install --force tealdeer

    # update neovim plugins
    update-nvim-plugins

    # update homebrew packages
    brew update
    brew upgrade --fetch-HEAD
    xattr -d com.apple.quarantine /Applications/LibreWolf.app || echo ""
end
