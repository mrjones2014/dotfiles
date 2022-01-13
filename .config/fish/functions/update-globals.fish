function update-globals
    # update homebrew packages
    brew update
    brew upgrade --fetch-HEAD

    # update sumneko lua-language-server via git and build from source
    pushd ~/git/personal/lua-language-server/
    git fetch
    set -l updates (git log HEAD..origin/master --oneline)
    if test -n "$updates"
        git merge && git submodule update --recursive
        pushd 3rd/luamake && compile/install.sh && popd && ./3rd/luamake/luamake rebuild
    end
    popd

    # update neovim plugins
    nvim --headless +PackerSync +qall!

    # update npm packages in all node versions
    # save to variable so we can reset to this version after updating packages
    set -l current_node_version (nvm current)
    for node_version in (nvm list | sed 's/.*\(v[0-9]*\.[0-9]*\.[0-9]*\).*/\1/')
        nvm use "$node_version"
        npm update -g
    end
    nvm use "$current_node_version"
end
