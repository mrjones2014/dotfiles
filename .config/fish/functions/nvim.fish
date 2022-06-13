function nvim
    set -l NVIM (which nvim)
    set -l LUA_LSP_VERSION (readlink (which lua-language-server) | grep -o "[0-9]\\+\\.[0-9]\\+\\.[0-9]\\+")

    if test (count $argv) -lt 1
        LUA_LSP_VERSION="$LUA_LSP_VERSION" "$NVIM" --startuptime /tmp/nvim-startuptime
        return
    end

    if test -d $argv[1]
        pushd $argv[1] && LUA_LSP_VERSION="$LUA_LSP_VERSION" "$NVIM" --startuptime /tmp/nvim-startuptime && popd
        return
    end

    LUA_LSP_VERSION="$LUA_LSP_VERSION" "$NVIM" --startuptime /tmp/nvim-startuptime $argv
end
