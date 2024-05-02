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

      -- sleek tab bar
      config.use_fancy_tab_bar = false
      config.show_new_tab_button_in_tab_bar = false
      config.tab_max_width = 22
      config.tab_bar_at_bottom = true
      config.hide_tab_bar_if_only_one_tab = true
      local hostname = wezterm.hostname()
      local function tab_title(tab)
        local title = string.sub(tab.tab_title or "", #hostname + 3)
        if title and #title > 0 then
          return title
        end
        return string.sub(tab.active_pane.title, #hostname + 3)
      end
      local function active_tab_idx(tabs)
        for _, tab in ipairs(tabs) do
          if tab.is_active then
            return tab.tab_index
          end
        end

        return -1
      end
      wezterm.on('format-tab-title', function(tab, tabs, panes, cf, hover, max_width)
        local title = tab_title(tab)
        -- 6 because of the two spaces below, plus 2 separators, plus tab index
        title = wezterm.truncate_left(title, max_width - 6)
        local i = tab.tab_index
        title = string.format(' %d %s ', i + 1, title)

        -- Catppuccin colors
        local bar_bg = '#11111b'
        local inactive_bg = '#585b70'
        local active_bg =  '#1e1e2e'
        local bg = inactive_bg
        local fg = '#cdd6f4'
        if tab.is_active then
          bg = active_bg
        end

        local active_idx = active_tab_idx(tabs)
        local end_sep_color = inactive_bg
        if i == (#tabs - 1) then
          end_sep_color = bar_bg
        elseif i == (active_idx - 1) then
          end_sep_color = active_bg
        elseif i < active_idx then
          end_sep_color = inactive_bg
        end

        return {
          { Background = { Color = bar_bg } },
          { Foreground = { Color = bar_bg } },
          { Text = "" },
          { Background = { Color = bg } },
          { Foreground = { Color = fg } },
          { Text = title },
          { Background = { Color = bar_bg } },
          { Foreground = { Color =  bg } },
          { Text = "" },
          { Background = { Color = end_sep_color } },
          { Foreground = { Color = bar_bg } },
          { Text = "" },
          { Background = { Color = bar_bg } },
          { Foreground = { Color = bar_bg } },
          { Text = "" },
        }
      end)

      config.color_scheme = 'Catppuccin Mocha'
      config.colors = {
        cursor_bg = '#40a02b',
      }
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

      local function find_vim_pane(tab)
        for _, pane in ipairs(tab:panes()) do
          if smart_splits.is_vim(pane) then
            return pane
          end
        end
      end

      local function active_pane_with_info(panes_with_info)
        for _, pane in ipairs(panes_with_info) do
          if pane.is_active then
            return pane
          end
        end

        return nil
      end

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
        -- Toggle zoom for neovim
        {
          key = 't',
          mods = 'CTRL',
          action = wezterm.action_callback(function(window, pane)
            local tab = pane:tab()
            local panes = tab:panes_with_info()
            local active_pane_info = active_pane_with_info(panes)
            if #panes == 1 then
              -- Open pane below if when there is only one pane and it is vim
              pane:split({ direction = "Bottom", size = 20 })
            else
              if not active_pane_info.is_zoomed then
                local vim = find_vim_pane(tab)
                if vim then
                  vim:activate()
                end
                tab:set_zoomed(true)
              else
                tab:set_zoomed(false)
                window:perform_action({ ActivatePaneDirection = 'Down' }, pane)
              end
            end
          end),
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
