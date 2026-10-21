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
    fileWidget = {
      command = "${pkgs.ripgrep}/bin/rg --files";
      options = [
        # Preview files with bat
        "--preview '${pkgs.bat}/bin/bat --color=always {}'"
        "--layout default"
      ];
    };

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
      fzf-history-widget-wrapped = /* fish */ ''
        history merge # make FZF search history from all sessions
        fzf-history-widget
        _prompt_move_to_bottom
      '';
      fzf-oldfiles-widget = /* fish */ ''
        set -l result (nvim -l ${nvim_oldfiles_script} | fzf --preview-window 'right,70%' --preview 'bat --style=numbers --color=always {} | head -100' | string collect)
        if test -n "$result"
            commandline -it -- (string escape -- $result)
        end
        commandline -f repaint
        _prompt_move_to_bottom
      '';
      fzf-vim-widget = /* fish */ ''
        set -l result (begin
                nvim -l ${nvim_oldfiles_script}
                ${pkgs.ripgrep}/bin/rg --files
            end | awk '!seen[$0]++' | fzf --tiebreak=index --preview-window 'right,70%' --preview 'bat --style=numbers --color=always {} | head -100' | string collect)
        commandline -f repaint
        _prompt_move_to_bottom
        if test -n "$result"
            $EDITOR $result
        end
      '';
      fzf-project-widget = /* fish */ ''
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

            set -l dir $(string match -r "^\S+" "$selected")
            echo "$HOME/git/$dir"
        end

        function _project_jump_get_projects
            # NB: built-in ls, not the lsd alias.
            printf (set_color --bold cyan)'%s'(set_color normal)'\n' (command ls "$HOME/git")
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
                clear
            end
            commandline -f repaint
        end
      '';
    };
  };
}
