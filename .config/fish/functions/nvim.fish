function nvim
    set -l NVIM (which nvim)
    if test (count $argv) -lt 1
        "$NVIM"
        return
    end

    if test -d $argv[1]
        pushd $argv[1] && "$NVIM" && popd
        return
    end

    "$NVIM" $argv
end
