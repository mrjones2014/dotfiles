{ lib, ... }: {
  programs.starship = {
    enable = true;
    settings = {
      format = lib.concatStrings [
        "$directory"
        "\${custom.git_server_icon}"
        "$git_branch"
        "$git_status"
        "\${custom.nix_shell}"
        "$line_break"
        "$character"
      ];
      right_format = "$cmd_duration";
      character = {
        success_symbol = "[ I ](bold bg:#89ca78 fg:#000000)[](fg:#89ca78)";
        error_symbol = "[ I ](bold bg:#ef596f fg:#000000)[](fg:#ef596f)";
        vicmd_symbol = "[ N ](bold bg:#89ca78 fg:#000000)[](fg:#89ca78)";
        vimcmd_replace_one_symbol =
          "[ R ](bold bg:#d55fde fg:#000000)[](fg:#d55fde)";
        vimcmd_replace_symbol =
          "[ R ](bold bg:#d55fde fg:#000000)[](fg:#d55fde)";
        vimcmd_visual_symbol =
          "[ V ](bold bg:#e5c07b fg:#000000)[](fg:#e5c07b)";
      };
      git_branch = {
        symbol = "";
        style = "bold #f74e27"; # git brand color
        format = "[$symbol$branch(:$remote_branch)]($style) ";
      };
      cmd_duration = {
        format = "[ $duration]($style)";
        style = "bold #586068";
      };
      directory = { read_only = " 󰌾"; };
      custom = {
        git_server_icon = {
          description =
            "Show a GitLab or GitHub icon depending on current git remote";
          when = "git rev-parse --is-inside-work-tree 2> /dev/null";
          command = ''
            GIT_REMOTE=$(git ls-remote --get-url 2> /dev/null); if [[ "$GIT_REMOTE" =~ "github" ]]; then printf "\e[1;37m\e[0m"; elif [[ "$GIT_REMOTE" =~ "gitlab" ]]; then echo ""; else echo "󰊢"; fi'';
          shell = [ "bash" "--noprofile" "--norc" ];
          style = "bold #f74e27"; # git brand color
          format = "[$output]($style)  ";
        };
        nix_shell = {
          description = "Show an indicator when inside a Nix ephemeral shell";
          when = ''[ "$IN_NIX_SHELL" != "" ]'';
          shell = [ "bash" "--noprofile" "--norc" ];
          style = "bold #6ec2e8";
          format = "[ ]($style)";
        };
      };
    };
  };
}
