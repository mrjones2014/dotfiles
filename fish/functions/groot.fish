function groot --description "cd to the root of the current git repository"
    set -l git_repo_root_dir (git rev-parse --show-toplevel 2>/dev/null)
    if test -n "$git_repo_root_dir"
        cd "$git_repo_root_dir"
        echo -e ""
        echo -e "      \e[1m\e[38;5;112m\^V//"
        echo -e "      \e[38;5;184m|\e[37m· ·\e[38;5;184m|      \e[94mI AM GROOT !"
        echo -e "    \e[38;5;112m- \e[38;5;184m\ - /"
        echo -e "     \_| |_/\e[38;5;112m¯"
        echo -e "       \e[38;5;184m\ \\"
        echo -e "     \e[38;5;124m__\e[38;5;184m/\e[38;5;124m_\e[38;5;184m/\e[38;5;124m__"
        echo -e "    |_______|"
        echo -e "     \     /"
        echo -e "      \___/\e[39m\e[00m"
        echo -e ""
    else
        echo "Not in a git repository."
    end
end
