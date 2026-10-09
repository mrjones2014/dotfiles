{
  osConfig,
  config,
  lib,
  isServer,
  ...
}:
with import ./tokyonight_palette.nix { inherit lib; };
let
  tmux = lib.getExe config.programs.tmux.package;

  icons = {
    normal = " ";
    prefix = " ";
    copy = " ";
    zoom = " ";
    server = " ";
  };

  directions = {
    h = "L";
    j = "D";
    k = "U";
    l = "R";
  };

  ifVim =
    key: fallback: "bind -n ${key} if -F '#{@pane-is-vim}' { send-keys ${key} } { ${fallback} }";

  moveBinds = lib.mapAttrsToList (key: letter: ifVim "C-${key}" "select-pane -${letter}") directions;

  resizeBinds = lib.mapAttrsToList (
    key: letter: ifVim "M-${key}" "resize-pane -${letter} 3"
  ) directions;

  copyModeNavBinds = lib.mapAttrsToList (
    key: letter: "bind -T copy-mode-vi C-${key} select-pane -${letter}"
  ) directions;
in
{
  programs = {
    tmux = {
      enable = true;
      baseIndex = 1;
      historyLimit = 50000;
      mouse = true;
      keyMode = "vi";
      focusEvents = true;
      newSession = true;
      disableConfirmationPrompt = true;
      terminal = "tmux-256color";
      shell = lib.getExe config.programs.fish.package;
      extraConfig = /* bash */ ''
        set -as terminal-features ',*:RGB'
        set -as terminal-features ',*:hyperlinks'
        set -as terminal-features ',*:usstyle'
        set -as terminal-features ',*:extkeys'
        set -g extended-keys on
        set -g extended-keys-format csi-u
        set -g set-clipboard on
        set -g renumber-windows on
        set -g display-time 4000

        # `#{b:pane_current_path}` renders $HOME as the username, but `M-n`
        # opens new windows there, so special-case it back to `~`.
        set -g automatic-rename on
        set -g allow-rename off
        set -g automatic-rename-format '#{?#{==:#{pane_current_path},${config.home.homeDirectory}},~,#{b:pane_current_path}}'

        set -g status-position bottom
        set -g status-justify left
        set -g status-style "bg=${bg},fg=${fg}"
        set -g status-left ""
        set -g status-left-length 0
        set -g window-status-separator " "
        set -g window-status-format         "#[bg=${terminal_black},fg=${fg_dark}] #I #W#{?window_zoomed_flag, ${icons.zoom} ,}#{?pane_synchronized,  ,} "
        set -g window-status-current-format "#[bg=${bg_dark},fg=${blue}] #I #W#{?window_zoomed_flag, ${icons.zoom} ,}#{?pane_synchronized,  ,} "
        set -g message-style "bg=${bg_highlight},fg=${fg}"
        set -g mode-style    "bg=${blue0},fg=${fg}"

        set -g status-right "#{?pane_in_mode,#[bg=${orange}#,fg=${bg}] ${icons.copy} ,#{?client_prefix,#[bg=${purple}#,fg=${bg}] ${icons.prefix} ,#[bg=${green}#,fg=${bg}] ${icons.normal} }}${lib.optionalString isServer "#[bg=${green},fg=${bg}] ${icons.server} mat@${osConfig.networking.hostName}.local "}#[bg=${bg}]"

        set -g pane-border-lines single
        set -g pane-border-status off
        set -g pane-border-indicators off
        set -g pane-border-style        "fg=${comment}"
        set -g pane-active-border-style "fg=${comment}"
        set -g popup-border-lines rounded
        set -g popup-style        "bg=${bg_dark}"
        set -g popup-border-style "fg=${blue}"

        bind '\' split-window -h -c "#{pane_current_path}"
        bind -   split-window -v -c "#{pane_current_path}"

        bind h swap-window -d -t -1
        bind l swap-window -d -t +1

        bind e copy-mode
        bind R source-file ${config.xdg.configHome}/tmux/tmux.conf \; display "tmux config reloaded"

        bind -n M-n     new-window -c "${config.home.homeDirectory}"
        bind -n M-Left  previous-window
        bind -n M-Right next-window

        bind -T copy-mode-vi v      send -X begin-selection
        bind -T copy-mode-vi C-v    send -X rectangle-toggle
        bind -T copy-mode-vi y      send -X copy-pipe-and-cancel
        bind -T copy-mode-vi Escape send -X cancel
        bind -T copy-mode-vi MouseDragEnd1Pane send -X copy-pipe-and-cancel

        # per-tab floating pane sessions 
        bind -n M-t if -F '#{m:_float_*,#{session_name}}' \
          { detach-client } \
          { run-shell -b "${tmux} display-popup -E -w 80% -h 80% -d '#{pane_current_path}' '${tmux} new-session -A -s _float_#{window_id}'" }

        # delete session when containing tab closes
        set-hook -g window-unlinked[1] 'run-shell -b "${tmux} kill-session -t _float_#{hook_window} 2>/dev/null || true"'

        # smart-splits 
        ${lib.concatStringsSep "\n" moveBinds}

        ${lib.concatStringsSep "\n" resizeBinds}

        ${lib.concatStringsSep "\n" copyModeNavBinds}
      '';
    };

    fish.interactiveShellInit = lib.mkBefore ''
      if not set -q TMUX; and not set -q NO_TMUX
          exec ${tmux} new-session -A -s 0
      end
    '';
  };
}
