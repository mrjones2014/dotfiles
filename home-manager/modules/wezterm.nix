{ pkgs, ... }:
let
  inherit (pkgs) stdenv;
  inherit (stdenv) isLinux;
in {
  home = {
    packages = with pkgs; [
      (nerdfonts.override { fonts = [ "FiraCode" ]; })
      maple-mono
    ];
    sessionVariables = { TERM = "wezterm"; };
  };
  programs.wezterm = {
    enable = true;
    colorSchemes.onedarkpro = {
      background = "#000000";
      foreground = "#abb2bf";
      selection_bg = "#d55fde";
      selection_fg = "#abb2bf";
      ansi = [
        "#000000"
        "#ef596f"
        "#89ca78"
        "#e5c07b"
        "#61afef"
        "#d55fde"
        "#2bbac5"
        "#abb2bf"
      ];
      brights = [
        "#434852"
        "#f38897"
        "#a9d89d"
        "#edd4a6"
        "#8fc6f4"
        "#e089e7"
        "#4bced8"
        "#c8cdd5"
      ];
    };
    extraConfig = ''
      local w = require('wezterm')
      local config = w.config_builder()
      local os_name = ${if isLinux then "'linux'" else "'macos'"}

      local w = require('wezterm')

      local function is_vim(pane)
        return pane:get_user_vars().IS_NVIM == 'true'
      end

      local direction_keys = {
        h = 'Left',
        j = 'Down',
        k = 'Up',
        l = 'Right',
      }

      local function split_nav(resize_or_move, key)
        return {
          key = key,
          mods = resize_or_move == 'resize' and 'META' or 'CTRL',
          action = w.action_callback(function(win, pane)
            if is_vim(pane) then
              -- pass the keys through to vim/nvim
              win:perform_action({
                SendKey = { key = key, mods = resize_or_move == 'resize' and 'META' or 'CTRL' },
              }, pane)
            else
              if resize_or_move == 'resize' then
                win:perform_action({ AdjustPaneSize = { direction_keys[key], 3 } }, pane)
              else
                win:perform_action({ ActivatePaneDirection = direction_keys[key] }, pane)
              end
            end
          end),
        }
      end

      -- macOS specific settings
      -- this setting behaves weirdly on linux
      config.hide_mouse_cursor_when_typing = os_name == 'macos'
      if os_name == 'macos' then
        config.window_decorations = 'RESIZE'
      end

      config.color_scheme = 'onedarkpro'
      config.cursor_blink_rate = 0
      -- config.font = w.font('Maple Mono NF')
      config.font = wezterm.font({
        family = 'Maple Mono',
        harfbuzz_features = {
          'cv03',
          'cv04',
          'ss01',
          'ss02',
          'ss03',
          'ss04',
          'ss05',
        },
      })
      config.font_size = 16
      config.use_fancy_tab_bar = true
      config.tab_bar_at_bottom = true
      config.hide_tab_bar_if_only_one_tab = true
      config.window_padding = {
        top = 0,
        bottom = 0,
        left = 0,
        right = 0,
      }
      config.debug_key_events = true
      config.inactive_pane_hsb = {
        saturation = 0.7,
        brightness = 0.6,
      }
      config.front_end = 'WebGpu'
      config.webgpu_power_preference = 'HighPerformance'

      -- simulate tmux prefix with leader
      config.leader = { key = "b", mods = "CTRL", timeout_milliseconds = 1000 }
      config.keys = {
        -- create split panes
        {
          key = '\\',
          mods = 'LEADER',
          action = w.action.SplitPane({ direction = 'Right', size = { Percent = 30 } }),
        },
        {
          key = '-',
          mods = 'LEADER',
          action = w.action.SplitPane({ direction = 'Down', size = { Percent = 20 } }),
        },
        -- move between split panes
        split_nav('move', 'h'),
        split_nav('move', 'j'),
        split_nav('move', 'k'),
        split_nav('move', 'l'),
        -- resize panes
        split_nav('resize', 'h'),
        split_nav('resize', 'j'),
        split_nav('resize', 'k'),
        split_nav('resize', 'l'),
        -- new window
        {
          key = 'n',
          mods = 'META',
          action = w.action.SpawnCommandInNewTab({
            args = { '${pkgs.fish}/bin/fish' },
            cwd = w.home_dir,
          }),
        },
        {
          key = 'LeftArrow',
          mods = 'META',
          action = w.action.ActivateTabRelative(-1),
        },
        {
          key = 'RightArrow',
          mods = 'META',
          action = w.action.ActivateTabRelative(1),
        },
        { key = '-', mods = 'SUPER', action = w.action.DecreaseFontSize },
        { key = '0', mods = 'SUPER', action = w.action.ResetFontSize },
        { key = '=', mods = 'SUPER', action = w.action.IncreaseFontSize },
        { key = 'c', mods = 'SUPER', action = w.action.CopyTo('Clipboard') },
        { key = 'v', mods = 'SUPER', action = w.action.PasteFrom('Clipboard') },
        { key = '[', mods = 'LEADER', action = w.action.ActivateCopyMode },
      }

      return config
    '';
  };
}
