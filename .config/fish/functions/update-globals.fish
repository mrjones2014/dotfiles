function update-globals
    brew update
    brew upgrade --fetch-HEAD
    pushd ~/git/personal/lua-language-server/
    git fetch
    set -l updates (git log HEAD..origin/master --oneline)
    if test -n "$updates"
        git merge && git submodule update --recursive
        pushd 3rd/luamake && compile/install.sh && popd && ./3rd/luamake/luamake rebuild
    end
    popd
    yarn global upgrade
    nvim --headless +PackerCompile +qall!
end
