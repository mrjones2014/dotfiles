{
  lib,
  pkgs,
  isServer,
  ...
}:
let
  palette = import ./tokyonight_palette.nix { inherit lib; };
  fishColor = lib.removePrefix "#";
in
with palette;
{
  programs.fish = {
    plugins = [
      {
        name = "tide";
        src = pkgs.fishPlugins.tide.src;
      }
    ];

    shellInit = /* fish */ ''
      set -g tide_left_prompt_items ${lib.optionalString isServer "server "}prompt_mode repo_pwd git newline shell_depth character
      set -g tide_right_prompt_items newline cmd_duration

      set -g tide_left_prompt_prefix ""
      set -g tide_left_prompt_separator_diff_color 
      set -g tide_left_prompt_separator_same_color ""
      set -g tide_left_prompt_suffix 
      set -g tide_right_prompt_prefix ""
      set -g tide_right_prompt_separator_diff_color ""
      set -g tide_right_prompt_separator_same_color ""
      set -g tide_right_prompt_suffix ""
      set -g tide_prompt_add_newline_before false
      set -g tide_prompt_icon_connection ""
      set -g tide_prompt_pad_items true
      set -g tide_prompt_transient_enabled true

      set -g tide_server_bg_color ${fishColor teal}
      set -g tide_server_color ${fishColor bg_dark}

      set -g tide_prompt_mode_bg_color_insert ${fishColor green}
      set -g tide_prompt_mode_bg_color_failure ${fishColor red}
      set -g tide_prompt_mode_bg_color_default ${fishColor blue}
      set -g tide_prompt_mode_bg_color_replace ${fishColor purple}
      set -g tide_prompt_mode_bg_color_visual ${fishColor yellow}
      set -g tide_prompt_mode_color ${fishColor bg_dark}

      set -g tide_repo_pwd_bg_color ${fishColor dark5}
      set -g tide_repo_pwd_color ${fishColor green}

      set -g tide_git_bg_color ${fishColor fg_gutter}
      set -g tide_git_bg_color_unstable ${fishColor fg_gutter}
      set -g tide_git_bg_color_urgent ${fishColor fg_gutter}
      set -g tide_git_color ${fishColor fg}
      set -g tide_git_color_conflicted ${fishColor yellow}
      set -g tide_git_color_dirty ${fishColor yellow}
      set -g tide_git_color_operation ${fishColor yellow}
      set -g tide_git_color_staged ${fishColor yellow}
      set -g tide_git_color_stash ${fishColor yellow}
      set -g tide_git_color_untracked ${fishColor yellow}
      set -g tide_git_color_upstream ${fishColor yellow}
      set -g tide_git_icon 
      set -g tide_jj_megamerge_icon 󱁉
      set -g tide_jj_unsynced_bookmark_icon '*'

      set -g tide_character_color ${fishColor green}
      set -g tide_character_color_failure ${fishColor green}
      set -g tide_character_icon ❯
      set -g tide_character_vi_icon_default ❯
      set -g tide_character_vi_icon_replace ❯
      set -g tide_character_vi_icon_visual ❯

      set -g tide_cmd_duration_bg_color normal
      set -g tide_cmd_duration_color ${fishColor dark3}
      set -g tide_cmd_duration_decimals 0
      set -g tide_cmd_duration_icon 
      set -g tide_cmd_duration_threshold 2000
    '';

    interactiveShellInit = /* fish */ ''
      # Avoid direnv printing before Tide can collapse the current prompt.
      set -g direnv_fish_mode eval_after_arrow
    '';

    functions = {
      _prompt_enter_transient = /* fish */ ''
        set -g _tide_transient
        set -g _tide_repaint
        commandline -f repaint
      '';

      _tide_pwd = /* fish */ ''
        set -l rendered_pwd

        if string match -q "$HOME/git/*" $PWD
            string replace "$HOME/git/" "" $PWD | read rendered_pwd
        else
            prompt_pwd | read rendered_pwd
        end

        string length -V -- $rendered_pwd | read -g _tide_pwd_len
        echo -n $rendered_pwd
      '';

      _tide_item_repo_pwd = /* fish */ ''
        set -l rendered_pwd @PWD@
        set -q IN_NIX_SHELL && set -a rendered_pwd (set_color ${fishColor blue5})' '
        _tide_print_item repo_pwd $rendered_pwd
      '';

      _tide_item_server = "_tide_print_item server ";

      _tide_item_prompt_mode = /* fish */ ''
        set -l icon 
        set -l bg_color $tide_prompt_mode_bg_color_insert

        switch $fish_bind_mode
            case default
                set icon 
                set bg_color $tide_prompt_mode_bg_color_default
            case replace replace_one
                set icon 
                set bg_color $tide_prompt_mode_bg_color_replace
            case visual
                set icon 
                set bg_color $tide_prompt_mode_bg_color_visual
        end

        if test "$_tide_status" != 0
            set icon 
            set bg_color $tide_prompt_mode_bg_color_failure
        end

        tide_prompt_mode_bg_color=$bg_color _tide_print_item prompt_mode $icon
      '';

      _tide_item_git = /* fish */ ''
        git rev-parse --git-dir --is-inside-git-dir 2>/dev/null | read -fL gdir in_gdir || return
        set -l git_icon $tide_git_icon

        set -l jj_indicators (jj log --ignore-working-copy -r 'bookmarks() | (::@ & description(glob:"wip: megamerge*"))' --no-graph -T \
            'if(self.contained_in("description(glob:\"wip: megamerge*\")"), "megamerge\n") ++ if(bookmarks.any(|bookmark| !bookmark.remote() && !bookmark.synced()), "unsynced_bookmark\n")' 2>/dev/null)

        if contains megamerge $jj_indicators
            set git_icon "$git_icon $tide_jj_megamerge_icon"
        end

        if contains unsynced_bookmark $jj_indicators
            set git_icon "$git_icon $tide_jj_unsynced_bookmark_icon"
        end

        if test -d $gdir/rebase-merge
            if not path is -v $gdir/rebase-merge/{msgnum,end}
                read -f step <$gdir/rebase-merge/msgnum
                read -f total_steps <$gdir/rebase-merge/end
            end
            test -f $gdir/rebase-merge/interactive && set -f operation rebase-i || set -f operation rebase-m
        else if test -d $gdir/rebase-apply
            if not path is -v $gdir/rebase-apply/{next,last}
                read -f step <$gdir/rebase-apply/next
                read -f total_steps <$gdir/rebase-apply/last
            end
            if test -f $gdir/rebase-apply/rebasing
                set -f operation rebase
            else if test -f $gdir/rebase-apply/applying
                set -f operation am
            else
                set -f operation am/rebase
            end
        else if test -f $gdir/MERGE_HEAD
            set -f operation merge
        else if test -f $gdir/CHERRY_PICK_HEAD
            set -f operation cherry-pick
        else if test -f $gdir/REVERT_HEAD
            set -f operation revert
        else if test -f $gdir/BISECT_LOG
            set -f operation bisect
        end

        test $in_gdir = true && set -l git_dir_opt -C $gdir/..
        set -l stat (git $git_dir_opt --no-optional-locks status --porcelain 2>/dev/null)
        string match -qr '(0|(?<stash>.*))\n(0|(?<conflicted>.*))\n(0|(?<staged>.*))
        (0|(?<dirty>.*))\n(0|(?<untracked>.*))(\n(0|(?<behind>.*))\t(0|(?<ahead>.*)))?' \
            "$(git $git_dir_opt stash list 2>/dev/null | count
          string match -r ^UU $stat | count
          string match -r ^[ADMR] $stat | count
          string match -r ^.[ADMR] $stat | count
          string match -r '^\?\?' $stat | count
          git rev-list --count --left-right @{upstream}...HEAD 2>/dev/null)"

        if test -n "$operation$conflicted"
            set -g tide_git_bg_color $tide_git_bg_color_urgent
        else if test -n "$staged$dirty$untracked"
            set -g tide_git_bg_color $tide_git_bg_color_unstable
        end

        _tide_print_item git $git_icon (set_color $tide_git_color_operation
          echo -ns ' '$operation ' '$step/$total_steps
          set_color $tide_git_color_upstream
          echo -ns ' ⇣'$behind ' ⇡'$ahead
          set_color $tide_git_color_stash
          echo -ns ' *'$stash
          set_color $tide_git_color_conflicted
          echo -ns ' ~'$conflicted
          set_color $tide_git_color_staged
          echo -ns ' +'$staged
          set_color $tide_git_color_dirty
          echo -ns ' !'$dirty
          set_color $tide_git_color_untracked
          echo -ns ' ?'$untracked)
      '';

      _tide_item_shell_depth = /* fish */ ''
        if test $SHLVL -gt 1
            set_color ${fishColor green}
            string repeat -Nn (math $SHLVL - 1) ❯
        end
      '';
    };
  };
}
