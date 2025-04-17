{ lib, isServer, ... }:
let
  # Define Tokyo Night color scheme variables
  bg_dark = "#1a1b26";
  bg = "#24283b";
  bg_highlight = "#292e42";
  terminal_black = "#414868";
  fg = "#c0caf5";
  fg_dark = "#a9b1d6";
  fg_gutter = "#3b4261";
  dark3 = "#545c7e";
  comment = "#565f89";
  dark5 = "#737aa2";
  blue0 = "#3d59a1";
  blue = "#7aa2f7";
  cyan = "#7dcfff";
  blue1 = "#2ac3de";
  blue2 = "#0db9d7";
  blue5 = "#89ddff";
  blue6 = "#b4f9f8";
  blue7 = "#394b70";
  magenta = "#bb9af7";
  magenta2 = "#ff007c";
  purple = "#9d7cd8";
  orange = "#ff9e64";
  yellow = "#e0af68";
  green = "#9ece6a";
  green1 = "#73daca";
  green2 = "#41a6b5";
  teal = "#1abc9c";
  red = "#f7768e";
  red1 = "#db4b4b";

  git_bg = fg_gutter;
  git_fg = fg;
  dir_bg = dark5;
  flake_bg = terminal_black;
in
{
  programs.starship = {
    enable = true;
    enableTransience = true;
    settings = {
      format = lib.concatStrings [
        (if isServer then "[ ](bg:${orange})[](bg:${orange} fg:${bg_dark})[  ](bg:${orange})" else "")
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
        "[❯](bg:${bg_dark} fg:${green}) "
      ];
      right_format = "$cmd_duration";
      character = {
        format = "$symbol";
        success_symbol = "[  ](bold bg:${green} fg:${bg_dark})[](fg:${green} bg:${dir_bg})";
        error_symbol = "[  ](bold bg:${red} fg:${bg_dark})[](fg:${red} bg:${dir_bg})";
        vicmd_symbol = "[  ](bold bg:${blue} fg:${bg_dark})[](fg:${blue} bg:${dir_bg})";
        vimcmd_replace_one_symbol =
          "[  ](bold bg:${purple} fg:${bg_dark})[](fg:${purple} bg:${dir_bg})";
        vimcmd_replace_symbol =
          "[  ](bold bg:${purple} fg:${bg_dark})[](fg:${purple} bg:${dir_bg})";
        vimcmd_visual_symbol =
          "[  ](bold bg:${yellow} fg:${bg_dark})[](fg:${yellow} bg:${dir_bg})";
      };
      cmd_duration.format = "[ $duration](bold ${dark3})";
      directory.format = "[ ](bg:${dir_bg})[$path](bold bg:${dir_bg} fg:${green})";
      git_commit.disabled = true;
      git_state.disabled = true;
      git_metrics.disabled = true;
      git_branch.format = "[ ](bg:${git_bg})[$branch](bg:${git_bg} fg:${git_fg})[ ](bg:${git_bg})";
      git_status.format = "[$all_status$ahead_behind](bg:${git_bg} fg:${git_fg})";
      custom = {
        git_server_icon = {
          description =
            "Show a GitLab or GitHub icon depending on current git remote";
          when = "git rev-parse --is-inside-work-tree 2> /dev/null";
          command = ''
            GIT_REMOTE=$(git ls-remote --get-url 2> /dev/null); if [[ "$GIT_REMOTE" =~ "github" ]]; then printf ""; elif [[ "$GIT_REMOTE" =~ "gitlab" ]]; then echo "󰮠"; else echo "󰊢"; fi'';
          shell = [ "bash" "--noprofile" "--norc" ];
          format = "[ ](bg:${git_bg})[$output](bg:${git_bg} fg:${git_fg})[ ](bg:${git_bg})";
        };
        dir_sep = {
          format = "[](fg:${dir_bg} bg:${bg_dark})";
          # not git and not nix
          when = ''! git rev-parse --is-inside-work-tree 2> /dev/null && [ "$IN_NIX_SHELL" = "" ]'';
          shell = [ "bash" "--noprofile" "--norc" ];
        };
        dir_sep_git = {
          format = "[](fg:${dir_bg} bg:${git_bg})";
          when = ''git rev-parse --is-inside-work-tree 2> /dev/null'';
          shell = [ "bash" "--noprofile" "--norc" ];
        };
        dir_sep_nix = {
          format = "[](fg:${dir_bg} bg:${terminal_black})";
          # not git but yes nix shell
          when = ''! git rev-parse --is-inside-work-tree 2> /dev/null && [ "$IN_NIX_SHELL" != "" ]'';
          shell = [ "bash" "--noprofile" "--norc" ];
        };
        branch_sep = {
          format = "[](fg:${git_bg})";
          when = ''git rev-parse --is-inside-work-tree 2> /dev/null && [ "$IN_NIX_SHELL" = "" ]'';
          shell = [ "bash" "--noprofile" "--norc" ];
        };
        branch_sep_nix_shell = {
          format = "[](fg:${dir_bg} bg:${flake_bg})";
          when = ''git rev-parse --is-inside-work-tree 2> /dev/null && [ "$IN_NIX_SHELL" != "" ]'';
          shell = [ "bash" "--noprofile" "--norc" ];
        };
        nix_shell = {
          description = "Show an indicator when inside a Nix ephemeral shell";
          when = ''[ "$IN_NIX_SHELL" != "" ]'';
          shell = [ "bash" "--noprofile" "--norc" ];
          format = "[ ](bg:${flake_bg})[](bg:${flake_bg} fg:${blue5})[ ](bg:${flake_bg})[](fg:${flake_bg} bg:${bg_dark})";
        };
      };
    };
  };
}
