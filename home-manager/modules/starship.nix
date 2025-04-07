{ lib, isServer, ... }: {
  programs.fish.functions.starship_transient_prompt_func = ''
    set -l dir $(starship module directory)
    set -l dir $(string trim "$dir")
    set -l branch $(starship module git_branch)
    set -l branch $(string trim "$branch")
    set -l icon $(starship module custom.git_server_icon)
    echo "${
      if isServer then
        "$(starship module username)$(starship module hostname)"
      else
        ""
    }$dir $icon $branch $(printf "\e[1;32m❯\e[0m ")"
  '';
  programs.starship = {
    enable = true;
    enableTransience = true;
    settings = {
      format = lib.concatStrings [
        "$username"
        "$hostname"
        "$directory"
        "\${custom.git_server_icon}"
        " $git_branch"
        "$git_status"
        "\${custom.nix_shell}"
        "\${custom.direnv} "
        "$python"
        "$line_break"
        "$character"
      ];
      right_format = "$cmd_duration";
      username.show_always = isServer;
      hostname.ssh_only = !isServer;
      character = {
        success_symbol = "[ I ](bold bg:#9ece6a fg:#000000)[](fg:#9ece6a)";
        error_symbol = "[ I ](bold bg:#f38ba8 fg:#000000)[](fg:#f38ba8)";
        vicmd_symbol = "[ N ](bold bg:#9ece6a fg:#000000)[](fg:#9ece6a)";
        vimcmd_replace_one_symbol =
          "[ R ](bold bg:#cba6f8 fg:#000000)[](fg:#cba6f8)";
        vimcmd_replace_symbol =
          "[ R ](bold bg:#cba6f8 fg:#000000)[](fg:#cba6f8)";
        vimcmd_visual_symbol =
          "[ V ](bold bg:#f9e2af fg:#000000)[](fg:#f9e2af)";
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
      directory.read_only = " 󰌾";
      git_commit.disabled = true;
      git_state.disabled = true;
      git_metrics.disabled = true;
      python = {
        format = "[\${symbol}\${virtualenv}]($style)";
        symbol = " ";
        pyenv_version_name = true;
      };
      custom = {
        git_server_icon = {
          description =
            "Show a GitLab or GitHub icon depending on current git remote";
          when = "git rev-parse --is-inside-work-tree 2> /dev/null";
          command = ''
            GIT_REMOTE=$(git ls-remote --get-url 2> /dev/null); if [[ "$GIT_REMOTE" =~ "github" ]]; then printf "\e[1;37m\e[0m"; elif [[ "$GIT_REMOTE" =~ "gitlab" ]]; then echo ""; else echo "󰊢"; fi'';
          shell = [ "bash" "--noprofile" "--norc" ];
          style = "bold #f74e27"; # git brand color
          format = "[$output]($style) ";
        };
        nix_shell = {
          description = "Show an indicator when inside a Nix ephemeral shell";
          when = ''[ "$IN_NIX_SHELL" != "" ]'';
          shell = [ "bash" "--noprofile" "--norc" ];
          style = "bold #6ec2e8";
          format = "[ ]($style)";
        };
        direnv = {
          description = "Show '.envrc' when using a direnv environment";
          when = ''[ "$DIRENV_DIR" != "" ] && [ "$IN_NIX_SHELL" != "" ]'';
          shell = [ "bash" "--noprofile" "--norc" ];
          style = "italic #f9e2af";
          format = "[via](italic #586068) [.envrc]($style)";
        };
      };
    };
  };
}
