function clear
    /usr/bin/clear
    # push prompt to bottom
    for i in (seq 1 $LINES)
        printf '\n'
    end
end
