function nvim

    if test (count $argv) -lt 1
       "$EDITOR" 
        return
    end

    if test -d $argv[1]
        pushd $argv[1] && "$EDITOR" && popd
        return
    end

    "$EDITOR" $argv
end
