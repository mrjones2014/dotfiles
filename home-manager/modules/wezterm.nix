{ pkgs, ... }:
let
  inherit (pkgs) stdenv;
  inherit (stdenv) isLinux;
  fish_path_lua_str = "'${pkgs.fish}/bin/fish'";
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
      local wezterm = require('wezterm')
      local config = wezterm.config_builder()
      local os_name = ${if isLinux then "'linux'" else "'macos'"}
      local smart_splits = wezterm.plugin.require('https://github.com/mrjones2014/smart-splits.nvim')

      -- macOS specific settings
      -- this setting behaves weirdly on linux
      config.hide_mouse_cursor_when_typing = os_name == 'macos'
      if os_name == 'macos' then
        config.window_decorations = 'RESIZE'
      end

      wezterm.on('augment-command-palette', function(window, pane)
      return {
        {
          brief = 'Update Plugins',
          icon = 'fa_puzzle_piece',
          action = wezterm.action_callback(function()
            -- TODO debug why the toast notification isn't showing, are plugins actually updating?
            window:toast_notification('Wezterm Plugins', 'Updating Wezterm plugins...', nil, 4000)
            wezterm.plugin.update_all()
          end)
        }
      }
      end)

      config.color_scheme = 'onedarkpro'
      config.cursor_blink_rate = 0
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
          action = wezterm.action.SplitPane({ direction = 'Right', size = { Percent = 30 } }),
        },
        {
          key = '-',
          mods = 'LEADER',
          action = wezterm.action.SplitPane({ direction = 'Down', size = { Percent = 20 } }),
        },
        -- new window
        {
          key = 'n',
          mods = 'META',
          action = wezterm.action.SpawnCommandInNewTab({
            args = { ${fish_path_lua_str} },
            cwd = wezterm.home_dir,
          }),
        },
        {
          key = 'LeftArrow',
          mods = 'META',
          action = wezterm.action.ActivateTabRelative(-1),
        },
        {
          key = 'RightArrow',
          mods = 'META',
          action = wezterm.action.ActivateTabRelative(1),
        },
        { key = '-', mods = 'SUPER', action = wezterm.action.DecreaseFontSize },
        { key = '0', mods = 'SUPER', action = wezterm.action.ResetFontSize },
        { key = '=', mods = 'SUPER', action = wezterm.action.IncreaseFontSize },
        { key = 'c', mods = 'SUPER', action = wezterm.action.CopyTo('Clipboard') },
        { key = 'v', mods = 'SUPER', action = wezterm.action.PasteFrom('Clipboard') },
        { key = '[', mods = 'LEADER', action = wezterm.action.ActivateCopyMode },
        { key = 'p', mods = 'SUPER', action = wezterm.action.ActivateCommandPalette },
      }

      smart_splits.apply_to_config(config)

      return config
    '';
  };
}
