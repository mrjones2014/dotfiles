{
  pkgs,
  lib,
  ...
}:
let
  key-bindings = [
    # you can use the command `fish_key_reader` to get the key codes to use
    {
      lhs = "ctrl-e";
      rhs = "fzf-vim-widget";
    }
    {
      lhs = "ctrl-g";
      rhs = "fzf-project-widget";
    }
    {
      lhs = "ctrl-f";
      rhs = "fzf-oldfiles-widget";
    }
    {
      lhs = "ctrl-r";
      rhs = "fzf-history-widget-wrapped";
    }
    {
      lhs = "ctrl-p";
      rhs = "fzf-jj-bookmarks";
    }
  ];
  nvim_oldfiles_script = pkgs.writeText "oldfiles.lua" /* lua */ ''
    -- Print MRU files from Neovim's ShaDa, filtered to real regular files under the current directory.
    -- Usage:
    --   nvim -l oldfiles.lua

    local function is_regular_file(p)
    	local st = vim.uv.fs_stat(p)
    	return st and st.type == "file"
    end

    local function normalize(p)
    	-- Expand ~/
    	if p:sub(1, 2) == "~/" then
    		p = vim.fn.expand(p)
    	end
    	return p
    end

    -- Get canonical CWD (so we handle symlinks)
    local function realpath(p)
    	return vim.uv.fs_realpath(p) or p
    end

    local cwd = realpath(".") .. "/"

    local function under_cwd(p)
    	local rp = realpath(p)
    	return rp and rp:sub(1, #cwd) == cwd
    end

    local function relative(p)
    	return p:gsub("^" .. vim.pesc(cwd), "")
    end

    -- Load ShaDa so v:oldfiles is populated
    pcall(function()
    	local shada_path = vim.fn.stdpath("state") .. "/shada/main.shada"
    	vim.cmd("silent! rshada! " .. vim.fn.fnameescape(shada_path))
    end)

    local oldfiles = vim.v.oldfiles or {}
    local seen = {}
    local out = {}

    for _, p in ipairs(oldfiles) do
    	p = normalize(p)
    	if not seen[p] and is_regular_file(p) and under_cwd(p) then
    		out[#out + 1] = relative(p)
    		seen[p] = true
    	end
    end

    for i = 1, #out do
    	io.stdout:write(out[i], "\n")
    end
  '';
in
{
  programs.fzf = {
    enable = true;
    defaultCommand = "${pkgs.ripgrep}/bin/rg --files";
    defaultOptions = [
      "--prompt='  '"
      "--marker=''"
      "--marker=' '"
      # this keybind should match the telescope ones in nvim config
      ''--bind="ctrl-d:preview-down,ctrl-f:preview-up"''
    ];
    fileWidgetCommand = "${pkgs.ripgrep}/bin/rg --files";
    fileWidgetOptions = [
      # Preview files with bat
      "--preview '${pkgs.bat}/bin/bat --color=always {}'"
      "--layout default"
    ];
  };
  programs.fish = {
    interactiveShellInit = ''
      for mode in insert default normal
      ${lib.concatMapStrings (keybind: ''
        bind -M $mode ${keybind.lhs} ${keybind.rhs}
      '') key-bindings}
      end
    '';
    functions = {

      fzf-history-widget-wrapped = ''
        history merge # make FZF search history from all sessions
        fzf-history-widget
        _prompt_move_to_bottom
      '';
      fzf-oldfiles-widget = ''
        set -l result (nvim -l ${nvim_oldfiles_script} | fzf --preview-window 'right,70%' --preview 'bat --style=numbers --color=always {} | head -100' | string collect)
        if test -n "$result"
            commandline -it -- (string escape -- $result)
        end
        commandline -f repaint
        _prompt_move_to_bottom
      '';
      fzf-project-widget = ''
        function _project_jump_get_icon
            set -l remote "$(git --work-tree $argv[1] --git-dir $argv[1]/.git ls-remote --get-url 2> /dev/null)"
            if string match -r "github.com" "$remote" >/dev/null
                set_color --bold normal
                echo -n 
            else if string match -r gitlab "$remote" >/dev/null
                set_color --bold FC6D26
                echo -n 
            else
                set_color --bold F74E27
                echo -n 󰊢
            end
        end

        function _project_jump_format_project
            set -l repo "$HOME/git/$argv[1]"
            set -l branch ""

            if test -d "$repo/.jj"
                set branch (jj -R $repo log --ignore-working-copy -r @- -n 1 --no-graph --no-pager --color always -T "separate(' ', format_short_change_id_with_hidden_and_divergent_info(self), self.bookmarks())" 2>/dev/null)
            else if test -d "$repo/.git"
                set branch (git --work-tree $repo --git-dir $repo/.git branch --show-current 2>/dev/null)
            end

            set_color --bold cyan
            echo -n "$argv[1]"
            echo -n " $(_project_jump_get_icon $repo)"
            set_color --bold f74e27
            if test -n "$branch"
                echo "  $branch"
            else
                echo
            end
        end

        function _project_jump_parse_project
            # check args
            set -f selected $argv[1]

            # if not coming from args
            if [ "$selected" = "" ]
                # check pipe
                read -f selected
            end

            # if still empty, return
            if [ "$selected" = "" ]
                return
            end

            set -l dir $(string trim "$(string match -r ".*(?=\s*󰊢||)" "$selected")")
            echo "$HOME/git/$dir"
        end

        function _project_jump_get_projects
            # make sure to use built-in ls, not exa
            for dir in $(command ls "$HOME/git")
                if test -d "$HOME/git/$dir"
                    echo "$(_project_jump_format_project $dir)"
                end
            end
        end

        function _project_jump_get_readme
            set -l dir $(_project_jump_parse_project "$argv[1]")
            if test -f "$dir/README.md"
                CLICOLOR_FORCE=1 COLORTERM=truecolor ${pkgs.glow}/bin/glow -p -s dark -w 150 "$dir/README.md"
            else
                echo
                echo $(set_color --bold) "README.md not found"
                echo
                ${pkgs.lsd}/bin/lsd -F $dir
            end
        end

        argparse 'format=' -- $argv
        if set -ql _flag_format
            _project_jump_get_readme $_flag_format
        else
            set -l selected $(_project_jump_get_projects | fzf --ansi --preview-window 'right,70%' --preview "fzf-project-widget --format {}")
            if test -n "$selected"
                cd $(_project_jump_parse_project "$selected")
            end
            commandline -f repaint
        end
      '';
      fzf-vim-widget = ''
        # modified from fzf-file-widget
        set -l commandline $(__fzf_parse_commandline)
        set -l dir $commandline[1]
        set -l fzf_query $commandline[2]
        set -l prefix $commandline[3]

        # "-path \$dir'*/\\.*'" matches hidden files/folders inside $dir but not
        # $dir itself, even if hidden.
        test -n "$FZF_CTRL_T_COMMAND"; or set -l FZF_CTRL_T_COMMAND "
        command find -L \$dir -mindepth 1 \\( -path \$dir'*/\\.*' -o -fstype 'sysfs' -o -fstype 'devfs' -o -fstype 'devtmpfs' \\) -prune \
        -o -type f -print \
        -o -type d -print \
        -o -type l -print 2> /dev/null | sed 's@^\./@@'"

        test -n "$FZF_TMUX_HEIGHT"; or set FZF_TMUX_HEIGHT 40%
        begin
            set -lx FZF_DEFAULT_OPTS "--height $FZF_TMUX_HEIGHT --reverse --bind=ctrl-z:ignore $FZF_DEFAULT_OPTS $FZF_CTRL_T_OPTS"
            eval "$FZF_CTRL_T_COMMAND | "(__fzfcmd)' -m --query "'$fzf_query'"' | while read -l r
                set result $result $r
            end
        end
        if [ -z "$result" ]
            _prompt_move_to_bottom
            commandline -f repaint
            return
        end
        set -l filepath_result
        for i in $result
            set filepath_result "$filepath_result$prefix"
            set filepath_result "$filepath_result$(string escape $i)"
            set filepath_result "$filepath_result "
        end
        _prompt_move_to_bottom
        commandline -f repaint
        $EDITOR $result
      '';
      fzf-jj-bookmarks = ''
        set -l selected_bookmark (jj bookmark list | fzf --height 40%)
        if test -n "$selected_bookmark"
            # parse the bookmark name out of the full bookmark info line
            set -l bookmark_name (string split ":" "$selected_bookmark" | head -n 1 | string trim)
            commandline -i " $bookmark_name "
        end
        commandline -f repaint
      '';
    };
  };
}
