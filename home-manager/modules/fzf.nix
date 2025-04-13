{ pkgs, lib, isDarwin, isServer, ... }:
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
      rhs = "fzf-file-widget-wrapped";
    }
    {
      lhs = "ctrl-r";
      rhs = "fzf-history-widget-wrapped";
    }
  ] ++ lib.lists.optionals (!isServer) [
    {
      lhs = "ctrl-p";
      rhs = "fzf-cmdp";
    }
  ];
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
      fzf-file-widget-wrapped = ''
        fzf-file-widget
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
          set -l branch $(git --work-tree $repo --git-dir $repo/.git branch --show-current)
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
    } // lib.optionalAttrs (!isServer) {
      fzf-cmdp = {
        description = "Command Palette";
        body = ''
          set tmpdir (set -q TMPDIR; and echo $TMPDIR; or mktemp -d)
          set fifo_path "$tmpdir/cmdp_result"
          set options_path "$tmpdir/cmdp_options"

          if not test -p $fifo_path
              mkfifo $fifo_path
          end

          set -l display_options "  SSH to nixos-server"
          set -l commands "ghostty -e ssh mat@nixos-server"

          # add 'copy git branch' only if in git repo
          if test -d .git
              set display_options $display_options "󰊢  Copy git branch"
              set commands $commands "git branch --show-current | tr -d '\n' | ${if isDarwin then "pbcopy" else "xclip -selection clipboard"}"
          end

          printf "%s\n" $display_options >"$options_path"
          zellij run -f -c --name "Command Palette" -y "2%" -- fish -c "
              cat $options_path | fzf --layout reverse > '$fifo_path'
          "

          set selected (cat $fifo_path)
          rm -f "$fifo_path"
          rm -f "$options_path"

          # find the index of the selected option
          set -l index -1
          for i in (seq (count $display_options))
              if test "$selected" = "$display_options[$i]"
                  set index $i
                  break
              end
          end

          set -l cmd $(string split ' ' $commands[$index])
          if test $index -gt 0
              nohup bash -c "$cmd" >/dev/null 2>&1 &
              disown
          else
              return 1
          end
        '';
      };
    };
  };
}
