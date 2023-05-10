if not infocmp wezterm &>/dev/null
    echo "Downloading Wezterm terminfo"

    set tempfile $(mktemp)
    set out_dir "~/.terminfo"

    if fish_is_root_user
        set out_dir /usr/share/terminfo
    end

    curl -# -o $tempfile https://raw.githubusercontent.com/wez/wezterm/master/termwiz/data/wezterm.terminfo

    echo "Compiling Wezterm terminfo"
    tic -x -o $out_dir $tempfile
    rm $tempfile
end
