function nvim
    set -l NVIM (which nvim)
    if test (count $argv) -lt 1
        "$NVIM" --startuptime /tmp/nvim-startuptime
        return
    end

    if test -d $argv[1]
        pushd $argv[1] && "$NVIM" --startuptime /tmp/nvim-startuptime && popd
        return
    end

    "$NVIM" --startuptime /tmp/nvim-startuptime $argv
end
