{ lib, isServer, ... }:
let
  palette = import ./tokyonight_palette.nix { inherit lib; };

  git_bg = palette.fg_gutter;
  git_fg = palette.fg;
  dir_bg = palette.dark5;
  server_bg = palette.teal;
  server_sep = color: if isServer then "[](fg:${server_bg} bg:${color})" else "";
in
with palette;
{
  programs.starship = {
    enable = true;
    enableTransience = true;
    settings = {
      command_timeout = 200;
      format = lib.concatStrings [
        (
          if isServer then
            "[ ](bg:${server_bg})[](bg:${server_bg} fg:${bg_dark})[  ](bg:${server_bg})"
          else
            ""
        )
        "$character"
        "$directory"
        "\${env_var.IN_NIX_SHELL}"
        "\${custom.dir_sep_no_git}"
        "\${custom.git_server_icon}"
        "$git_status"
        "$line_break"
        "$shlvl"
        "[❯](bg:${bg_dark} fg:${green}) "
      ];
      right_format = "$cmd_duration";
      shlvl = {
        disabled = false;
        symbol = "❯";
        format = "[$symbol]($style)";
        repeat = true;
        repeat_offset = 1;
        threshold = 0;
      };
      character = {
        format = "$symbol";
        success_symbol = "${server_sep green}[  ](bold bg:${green} fg:${bg_dark})[](fg:${green} bg:${dir_bg})";
        error_symbol = "${server_sep red}[  ](bold bg:${red} fg:${bg_dark})[](fg:${red} bg:${dir_bg})";
        vicmd_symbol = "${server_sep blue}[  ](bold bg:${blue} fg:${bg_dark})[](fg:${blue} bg:${dir_bg})";
        vimcmd_replace_one_symbol = "${server_sep purple}[  ](bold bg:${purple} fg:${bg_dark})[](fg:${purple} bg:${dir_bg})";
        vimcmd_replace_symbol = "${server_sep purple}[  ](bold bg:${purple} fg:${bg_dark})[](fg:${purple} bg:${dir_bg})";
        vimcmd_visual_symbol = "${server_sep yellow}[  ](bold bg:${yellow} fg:${bg_dark})[](fg:${yellow} bg:${dir_bg})";
      };
      cmd_duration.format = "[ $duration](bold ${dark3})";
      directory.format = "[ ](bg:${dir_bg})[$path](bg:${dir_bg} fg:${green})";
      env_var.IN_NIX_SHELL.format = "[ ](bg:${dir_bg})[](bg:${dir_bg} fg:${blue5})[ ](bg:${dir_bg})";
      git_status.format = "[$all_status$ahead_behind](bg:${git_bg} fg:${yellow})[](fg:${git_bg} bg:${bg_dark})";
      custom = {
        git_server_icon = {
          description = "Show a GitLab or GitHub icon depending on current git remote";
          when = "git rev-parse --is-inside-work-tree 2> /dev/null";
          command = ''GIT_REMOTE=$(git ls-remote --get-url 2> /dev/null); if [[ "$GIT_REMOTE" =~ "github" ]]; then printf ""; elif [[ "$GIT_REMOTE" =~ "gitlab" ]]; then echo "󰮠"; else echo "󰊢"; fi'';
          shell = [
            "bash"
            "--noprofile"
            "--norc"
          ];
          format = "([](fg:${dir_bg} bg:${git_bg})[ ](bg:${git_bg})[$output](bg:${git_bg} fg:${git_fg})[ ](bg:${git_bg}))";
        };
        dir_sep_no_git = {
          description = "Show rounded separator when not in a git repo";
          format = "[](fg:${dir_bg} bg:${bg_dark})";
          when = "! git rev-parse --is-inside-work-tree 2> /dev/null";
          shell = [
            "bash"
            "--noprofile"
            "--norc"
          ];
        };
      };
    };
  };
}
