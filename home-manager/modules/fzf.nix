{ pkgs, lib, ... }:
let
  key-bindings = [
    # you can use the command `fish_key_reader` to get the key codes to use
    {
      # ctrl+e
      lhs = "\\ce";
      rhs = "fzf-vim-widget";
    }
    {
      # ctrl+g
      lhs = "\\a";
      rhs = "fzf-project-widget";
    }
    {
      # ctrl+t
      lhs = "\\ct";
      rhs = "fzf-file-widget-wrapped";
    }
  ];
in {
  programs.fzf = {
    enable = true;
    defaultCommand = "${pkgs.ripgrep}/bin/rg --files";
    defaultOptions = [ "--prompt='  '" "--marker=''" "--marker=' '" ];
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
    functions.fzf-file-widget-wrapped = ''
      fzf-file-widget
      _prompt_move_to_bottom
    '';
    functions.fzf-project-widget = ''
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
        set -l branch (git --work-tree $repo --git-dir $repo/.git branch --show-current)
        set_color --bold cyan
        echo -n "$argv[1]"
        echo -n " $(_project_jump_get_icon $repo)"
        set_color --bold f74e27
        echo "  $branch"
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

        set -l dir (string trim "$(string match -r ".*(?=\s*󰊢||)" "$selected")")
        echo "$HOME/git/$dir"
      end

      function _project_jump_get_projects
        # make sure to use built-in ls, not exa
        for dir in (command ls "$HOME/git")
          if test -d "$HOME/git/$dir"
            echo "$(_project_jump_format_project $dir)"
          end
        end
      end

      function _project_jump_get_readme
        set -l dir (_project_jump_parse_project "$argv[1]")
        if test -f "$dir/README.md"
          ${pkgs.glow}/bin/glow -p -s dark -w 150 "$dir/README.md"
        else
          echo
          echo (set_color --bold) "README.md not found"
          echo
          ${pkgs.exa}/bin/exa --icons -s type -F --color=always $dir
        end
      end

      argparse 'format=' -- $argv
      if set -ql _flag_format
        _project_jump_get_readme $_flag_format
      else
        set -l selected (_project_jump_get_projects | fzf --ansi --preview-window 'right,70%' --preview "fzf-project-widget --format {}" --bind "space:execute(echo 'pickfile:{}')+abort")
        set -l proj_dir (string replace -r "^pickfile:" "" "$selected" || true)
        if test -n "$proj_dir"
          cd (_project_jump_parse_project "$proj_dir")
        end
        commandline -f repaint
        # if instructed to pick a file, do it
        if [ "$(string length \"$proj_dir\")" != "$(string length \"$selected\")" ]
          set -l selected_file (fzf --preview-window 'right,70%' --preview "${pkgs.bat}/bin/bat {}")
          if test -n "$selected_file"
            $EDITOR "$selected_file"
          end
        end
      end
    '';
    functions.fzf-vim-widget = ''
      # modified from fzf-file-widget
      set -l commandline (__fzf_parse_commandline)
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
        eval "$FZF_CTRL_T_COMMAND | "(__fzfcmd)' -m --query "'$fzf_query'"' | while read -l r; set result $result $r; end
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
  };
}
