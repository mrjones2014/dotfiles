function _ctrlg_get_related_panes
    if tmux has-session -t "float-$TMUX_PANE"
        echo "float-$TMUX_PANE"
    end
end