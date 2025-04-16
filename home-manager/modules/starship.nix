{ lib, isServer, ... }: {
  # programs.fish.functions.starship_transient_prompt_func = ''
  #   set -l dir $(starship module directory)
  #   set -l dir $(string trim "$dir")
  #   set -l branch $(starship module git_branch)
  #   set -l branch $(string trim "$branch")
  #   set -l icon $(starship module custom.git_server_icon)
  #   echo "${
  #     if isServer then
  #       "$(starship module username)$(starship module hostname)"
  #     else
  #       ""
  #   }$dir $icon $branch $(printf "\e[1;32m❯\e[0m ")"
  # '';
  programs.starship = {
    enable = true;
    enableTransience = true;
    settings = {
      format = lib.concatStrings [
        (if isServer then "[ ](bg:#ff9e64)[](bg:#ff9e64 fg:#1a1b26)[  ](bg:#ff9e64)" else "")
        "$character"
        "$directory"
        "\${custom.dir_sep}"
        "\${custom.dir_sep_git}"
        "\${custom.dir_sep_nix}"
        "\${custom.git_server_icon}"
        "$git_branch"
        "$git_status"
        "\${custom.branch_sep}"
        "\${custom.branch_sep_nix_shell}"
        "\${custom.nix_shell}"
        "$line_break"
        "[❯](bg:#1a1b26 fg:#9ece6a) "
      ];
      right_format = "$cmd_duration";
      character = {
        format = "$symbol";
        success_symbol = "[  ](bold bg:#9ece6a fg:#1a1b26)[](fg:#9ece6a bg:#7aa2f7)";
        error_symbol = "[  ](bold bg:#f38ba8 fg:#1a1b26)[](fg:#f38ba8 bg:#7aa2f7)";
        vicmd_symbol = "[  ](bold bg:#9ece6a fg:#1a1b26)[](fg:#9ece6a bg:#7aa2f7)";
        vimcmd_replace_one_symbol =
          "[  ](bold bg:#cba6f8 fg:#1a1b26)[](fg:#cba6f8 bg:#7aa2f7)";
        vimcmd_replace_symbol =
          "[  ](bold bg:#cba6f8 fg:#1a1b26)[](fg:#cba6f8 bg:#7aa2f7)";
        vimcmd_visual_symbol =
          "[  ](bold bg:#f9e2af fg:#1a1b26)[](fg:#f9e2af bg:#7aa2f7)";
      };
      git_branch.format = "[ ](bg:#737aa2)[$branch](bg:#737aa2 fg:#9ece6a)[ ](bg:#737aa2)";
      git_status.format = "[$all_status$ahead_behind](bg:#737aa2 fg:#9ece6a)";
      directory.format = "[ ](bg:#7aa2f7 fg:#7aa2f7)[$path](bold bg:#7aa2f7 fg:#1a1b26)";
      git_commit.disabled = true;
      git_state.disabled = true;
      git_metrics.disabled = true;
      cmd_duration.format = "[ $duration](bold #586068)";
      custom = {
        git_server_icon = {
          description =
            "Show a GitLab or GitHub icon depending on current git remote";
          when = "git rev-parse --is-inside-work-tree 2> /dev/null";
          command = ''
            GIT_REMOTE=$(git ls-remote --get-url 2> /dev/null); if [[ "$GIT_REMOTE" =~ "github" ]]; then printf ""; elif [[ "$GIT_REMOTE" =~ "gitlab" ]]; then echo "󰮠"; else echo "󰊢"; fi'';
          shell = [ "bash" "--noprofile" "--norc" ];
          format = "[ ](bg:#737aa2)[$output](bg:#737aa2 fg:#9ece6a)[ ](bg:#737aa2)";
        };
        dir_sep = {
          format = "[](fg:#7aa2f7 bg:#1a1b26)";
          # not git and not nix
          when = ''! git rev-parse --is-inside-work-tree 2> /dev/null && [ "$IN_NIX_SHELL" = "" ]'';
          shell = [ "bash" "--noprofile" "--norc" ];
        };
        dir_sep_git = {
          format = "[](fg:#7aa2f7 bg:#737aa2)";
          when = ''git rev-parse --is-inside-work-tree 2> /dev/null'';
          shell = [ "bash" "--noprofile" "--norc" ];
        };
        dir_sep_nix = {
          format = "[](fg:#7aa2f7 bg:#414868)";
          # not git but yes nix shell
          when = ''! git rev-parse --is-inside-work-tree 2> /dev/null && [ "$IN_NIX_SHELL" != "" ]'';
          shell = [ "bash" "--noprofile" "--norc" ];
        };
        branch_sep = {
          format = "[](fg:#737aa2)";
          when = ''git rev-parse --is-inside-work-tree 2> /dev/null && [ "$IN_NIX_SHELL" = "" ]'';
          shell = [ "bash" "--noprofile" "--norc" ];
        };
        branch_sep_nix_shell = {
          format = "[](fg:#737aa2 bg:#414868)";
          when = ''git rev-parse --is-inside-work-tree 2> /dev/null && [ "$IN_NIX_SHELL" != "" ]'';
          shell = [ "bash" "--noprofile" "--norc" ];
        };
        nix_shell = {
          description = "Show an indicator when inside a Nix ephemeral shell";
          when = ''[ "$IN_NIX_SHELL" != "" ]'';
          shell = [ "bash" "--noprofile" "--norc" ];
          format = "[ ](bg:#414868)[](bg:#414868 fg:#89ddff)[ ](bg:#414868)[](fg:#414868 bg:#1a1b26)";
        };
      };
    };
  };
}
