{ pkgs, lib, ... }:
let
  palette = import ../components/tokyonight_palette.nix { inherit lib; };
  statusline =
    let
      jq = "${pkgs.jq}/bin/jq";
    in
    pkgs.writeShellScript "claude-code-statusline" ''
      #!/usr/bin/env bash

      # read json from stdin
      input="$(cat)"
      model=$(echo "$input" | ${jq} -r '.model.display_name')
      percent_context=$(echo "$input" | ${jq} -r '.context_window.used_percentage // 0' | cut -d. -f1)
      total_cost=$(echo "$input" | ${jq} -r '.cost.total_cost_usd // 0')
      session_id=$(echo "$input" | ${jq} -r '.session_id // ""')
      vim_mode=$(echo "$input" | ${jq} -r '.vim.mode // ""')
      # ANSI color helpers
      reset=$'\e[0m'
      bold=$'\e[1m'
      # RGB colors from tokyonight palette
      fg_rgb() { printf '\e[38;2;%sm' "$1"; }
      bg_rgb() { printf '\e[48;2;%sm' "$1"; }
      # Colors (RGB values)
      black="${palette.hexToAnsiRgb palette.bg_dark}"
      green="${palette.hexToAnsiRgb palette.green}"
      blue="${palette.hexToAnsiRgb palette.blue}"
      yellow="${palette.hexToAnsiRgb palette.yellow}"
      cyan="${palette.hexToAnsiRgb palette.cyan}"
      red="${palette.hexToAnsiRgb palette.red}"
      gray="${palette.hexToAnsiRgb palette.dark5}"
      surface0="${palette.hexToAnsiRgb palette.fg_gutter}"
      fg="${palette.hexToAnsiRgb palette.fg}"
      # Separators
      sep_right=""
      sep_left=""
      # Vim mode styling
      case "$vim_mode" in
        normal|"")
          mode_icon=""
          mode_bg="$green"
          ;;
        insert)
          mode_icon=""
          mode_bg="$blue"
          ;;
        *)
          mode_icon=""
          mode_bg="$green"
          ;;
      esac
      # Context color based on percentage
      if [ "$percent_context" -lt 50 ]; then
        ctx_color="$green"
      elif [ "$percent_context" -lt 80 ]; then
        ctx_color="$yellow"
      else
        ctx_color="$red"
      fi
      # Build status line
      out=""
      # Vim mode segment
      out+="$(bg_rgb "$mode_bg")$(fg_rgb "$black")$bold $mode_icon $reset"
      out+="$(fg_rgb "$mode_bg")$(bg_rgb "$gray")$sep_right$reset"
      # Model segment
      out+="$(bg_rgb "$gray")$(fg_rgb "$fg")  $model $reset"
      out+="$(fg_rgb "$gray")$(bg_rgb "$surface0")$sep_right$reset"
      # Context segment
      out+="$(bg_rgb "$surface0")$(fg_rgb "$ctx_color")  $percent_context%% $reset"
      # Spacer (just reset background)
      out+="$(bg_rgb "$surface0") $reset"
      # Cost segment (right side)
      out+="$(bg_rgb "$surface0")$(fg_rgb "$fg") \$$total_cost $reset"
      # Session ID (truncated to 8 chars)
      if [ -n "$session_id" ]; then
        short_id="''${session_id:0:8}"
        out+="$(fg_rgb "$surface0")$(bg_rgb "$gray")$sep_left$reset"
        out+="$(bg_rgb "$gray")$(fg_rgb "$fg")  $short_id $reset"
      fi
      printf '%s' "$out"
    '';
in
{
  home.packages = with pkgs; [
    ast-grep
    fd
    jq
    parallel
    ripgrep
    sd
    yq-go
  ];
  programs.claude-code = {
    enable = true;
    memory.text = ''
      ## Installed CLI tools

      - **ast-grep** is installed — use for structural code searches and transformations on supported languages
      - **fd** is installed — prefer over `find` for file finding by name/pattern
      - **GNU parallel** is installed — use for concurrent shell tasks when beneficial
      - **jq** is installed — use for JSON processing in shell pipelines
      - **ripgrep** (`rg`) is installed — prefer over `grep` for shell searches
      - **sd** is installed — prefer over `sed` for find-and-replace in files
      - **yq** is installed — use for YAML processing in shell pipelines
    '';
    settings = {
      # do not ever commit anything on my behalf
      includeGitInstructions = false;
      attribution = {
        commit = "";
        pr = "";
      };
      spinnerTipsEnabled = false;
      feedbackSurveyRate = 0;
      defaultMode = "plan";
      statusline = {
        type = "command";
        command = "${statusline}/bin/claude-code-statusline";
      };
    };
  };
}
