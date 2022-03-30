function update-globals --description "Update brew packages, some cargo packages, and npm global packages"
    # update homebrew packages
    brew update
    brew upgrade --fetch-HEAD
    xattr -d com.apple.quarantine /Applications/LibreWolf.app

    # update cargo packages
    cargo install atuin
    cargo install caniuse-rs
    cargo install mdbook
    cargo install stylua
    cargo install tealdeer

    # update neovim plugins
    update-nvim-plugins

    # update npm packages in all node versions
    # save to variable so we can reset to this version after updating packages
    set -l current_node_version (nvm current)
    for node_version in (nvm list | sed 's/.*\(v[0-9]*\.[0-9]*\.[0-9]*\).*/\1/')
        nvm use "$node_version"
        npm update -g
    end
    nvm use "$current_node_version"

    pushd ~/.config/hammerspoon/Spoons/VimMode.spoon/ && git pull && popd
end
