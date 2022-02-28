function exit
    if test -n "$TMUX" && test -n "$TMUX_PANE" && test -n (tmux list-sessions | grep "float-$TMUX_PANE")
        tmux kill-session -t "float-$TMUX_PANE" >/dev/null
    end

    builtin exit
end
