{ lib, isServer, ... }:
let
  # Define Tokyo Night color scheme variables
  bg = "#1a1b26"; # Background
  fg = "#c0caf5"; # Foreground
  blue = "#7aa2f7"; # Blue
  green = "#9ece6a"; # Green
  yellow = "#f9e2af"; # Yellow
  red = "#f38ba8"; # Red
  purple = "#cba6f8"; # Purple
  cyan = "#89ddff"; # Cyan
  orange = "#ff9e64"; # Orange
  comment = "#737aa2"; # Comment
  dark_blue = "#414868"; # Dark Blue
  gray = "#586068"; # Gray
in
{
  programs.starship = {
    enable = true;
    enableTransience = true;
    settings = {
      format = lib.concatStrings [
        (if isServer then "[ ](bg:${orange})[](bg:${orange} fg:${bg})[  ](bg:${orange})" else "")
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
        "[❯](bg:${bg} fg:${green}) "
      ];
      right_format = "$cmd_duration";
      character = {
        format = "$symbol";
        success_symbol = "[  ](bold bg:${green} fg:${bg})[](fg:${green} bg:${blue})";
        error_symbol = "[  ](bold bg:${red} fg:${bg})[](fg:${red} bg:${blue})";
        vicmd_symbol = "[  ](bold bg:${green} fg:${bg})[](fg:${green} bg:${blue})";
        vimcmd_replace_one_symbol =
          "[  ](bold bg:${purple} fg:${bg})[](fg:${purple} bg:${blue})";
        vimcmd_replace_symbol =
          "[  ](bold bg:${purple} fg:${bg})[](fg:${purple} bg:${blue})";
        vimcmd_visual_symbol =
          "[  ](bold bg:${yellow} fg:${bg})[](fg:${yellow} bg:${blue})";
      };
      git_branch.format = "[ ](bg:${comment})[$branch](bg:${comment} fg:${green})[ ](bg:${comment})";
      git_status.format = "[$all_status$ahead_behind](bg:${comment} fg:${green})";
      directory.format = "[ ](bg:${blue} fg:${blue})[$path](bold bg:${blue} fg:${bg})";
      git_commit.disabled = true;
      git_state.disabled = true;
      git_metrics.disabled = true;
      cmd_duration.format = "[ $duration](bold ${gray})";
      custom = {
        git_server_icon = {
          description =
            "Show a GitLab or GitHub icon depending on current git remote";
          when = "git rev-parse --is-inside-work-tree 2> /dev/null";
          command = ''
            GIT_REMOTE=$(git ls-remote --get-url 2> /dev/null); if [[ "$GIT_REMOTE" =~ "github" ]]; then printf ""; elif [[ "$GIT_REMOTE" =~ "gitlab" ]]; then echo "󰮠"; else echo "󰊢"; fi'';
          shell = [ "bash" "--noprofile" "--norc" ];
          format = "[ ](bg:${comment})[$output](bg:${comment} fg:${green})[ ](bg:${comment})";
        };
        dir_sep = {
          format = "[](fg:${blue} bg:${bg})";
          # not git and not nix
          when = ''! git rev-parse --is-inside-work-tree 2> /dev/null && [ "$IN_NIX_SHELL" = "" ]'';
          shell = [ "bash" "--noprofile" "--norc" ];
        };
        dir_sep_git = {
          format = "[](fg:${blue} bg:${comment})";
          when = ''git rev-parse --is-inside-work-tree 2> /dev/null'';
          shell = [ "bash" "--noprofile" "--norc" ];
        };
        dir_sep_nix = {
          format = "[](fg:${blue} bg:${dark_blue})";
          # not git but yes nix shell
          when = ''! git rev-parse --is-inside-work-tree 2> /dev/null && [ "$IN_NIX_SHELL" != "" ]'';
          shell = [ "bash" "--noprofile" "--norc" ];
        };
        branch_sep = {
          format = "[](fg:${comment})";
          when = ''git rev-parse --is-inside-work-tree 2> /dev/null && [ "$IN_NIX_SHELL" = "" ]'';
          shell = [ "bash" "--noprofile" "--norc" ];
        };
        branch_sep_nix_shell = {
          format = "[](fg:${comment} bg:${dark_blue})";
          when = ''git rev-parse --is-inside-work-tree 2> /dev/null && [ "$IN_NIX_SHELL" != "" ]'';
          shell = [ "bash" "--noprofile" "--norc" ];
        };
        nix_shell = {
          description = "Show an indicator when inside a Nix ephemeral shell";
          when = ''[ "$IN_NIX_SHELL" != "" ]'';
          shell = [ "bash" "--noprofile" "--norc" ];
          format = "[ ](bg:${dark_blue})[](bg:${dark_blue} fg:${cyan})[ ](bg:${dark_blue})[](fg:${dark_blue} bg:${bg})";
        };
      };
    };
  };
}
