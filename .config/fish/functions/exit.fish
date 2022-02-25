function exit
    if test -n "$TMUX"
        tmux kill-session -t "float-$TMUX_PANE" >/dev/null
    end

    builtin exit
end
