{ pkgs, ... }:
let fish_path_lua_str = "'${pkgs.fish}/bin/fish'";
in {
  home = {
    packages = with pkgs; [ maple-mono ];
    sessionVariables = { TERM = "wezterm"; };
  };
  programs.wezterm = {
    enable = true;
    extraConfig = ''
      local wezterm = require('wezterm')
      local config = wezterm.config_builder()
      local smart_splits = wezterm.plugin.require('https://github.com/mrjones2014/smart-splits.nvim')

      config.hide_mouse_cursor_when_typing = true
      config.window_decorations = 'RESIZE'

      -- sleek tab bar
      local tab_max_width = 30
      config.use_fancy_tab_bar = false
      config.show_new_tab_button_in_tab_bar = false
      config.tab_max_width = tab_max_width
      config.tab_bar_at_bottom = true
      config.hide_tab_bar_if_only_one_tab = false
      config.switch_to_last_active_tab_when_closing_tab = true

      local function tab_title(tab, is_mux_win)
        local title
        if is_mux_win then
          title = tab:get_title()
        else
          title = tab.tab_title
        end

        if title and #title > 0 then
          return title
        end

        -- remove hostname
        if is_mux_win then
          title = tab:window():gui_window():active_pane():get_title()
        else
          title = tab.active_pane.title
        end
        return string.gsub(title, '^%[?[%a%d\\-]%]? ', "")
      end

      local function format_tab_title(tab, idx, max_width, is_mux_win)
        -- 6 because of the two spaces below, plus 2 separators, plus tab index
        return string.format(' %d %s ', idx, wezterm.truncate_left(tab_title(tab, is_mux_win), max_width - 6))
      end

      local function active_tab_idx(tabs)
        for _, tab in ipairs(tabs) do
          if tab.is_active then
            return tab.tab_index
          end
        end

        return -1
      end
      wezterm.on('update-status', function(window)
        local mux_win = window:mux_window()
        local total_width = mux_win:active_tab():get_size().cols
        local all_tabs = mux_win:tabs()
        local tabs_max_width = config.tab_max_width * #all_tabs
        local tabs_total_width = 0
        for _, tab in ipairs(mux_win:tabs()) do
          tabs_total_width = tabs_total_width + #format_tab_title(tab, 0, tab_max_width, true) + 6
        end
        window:set_left_status(string.rep(' ', (total_width / 2) - (tabs_total_width / 2)))
      end)
      wezterm.on('format-tab-title', function(tab, tabs)
        local i = tab.tab_index
        local title = format_tab_title(tab, i + 1, tab_max_width)

        -- tokyonight colors
        local bar_bg = '#292e42'
        local inactive_bg = '#585b70'
        local active_bg =  '#1e1e2e'
        local bg = inactive_bg
        local fg = '#cdd6f4'
        if tab.is_active then
          bg = active_bg
        end

        local active_idx = active_tab_idx(tabs)
        local end_sep_color = bar_bg
        if i == (active_idx - 1) then
          end_sep_color = active_bg
        end

        return {
          { Background = { Color = bar_bg } },
          { Foreground = { Color = bg } },
          { Text = "▐" },
          { Background = { Color = bg } },
          { Foreground = { Color = fg } },
          { Text = title },
          { Text = has_unseen_output and '  ' or "" },
          { Background = { Color = bar_bg } },
          { Foreground = { Color =  bg } },
          { Text = "▌" },
          { Background = { Color = bar_bg } },
          { Foreground = { Color = bar_bg } },
        }
      end)

      config.color_scheme = 'tokyonight_night'
      config.colors = {
        tab_bar = {
          background = '#292e42'
        }
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

      local function basename(pane)
        local proc
        if pane.foreground_process_name then
          proc = pane.foreground_process_name
        elseif pane.get_foreground_process_name then
          proc = pane:get_foreground_process_name()
        else
          return ""
        end
        return string.gsub(proc, '(.*[/\\])(.*)', '%2')
      end

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
        -- show btop in new tab
        {
          key = 'p',
          mods = 'META',
          action = wezterm.action.SpawnCommandInNewTab({
            args = { '${pkgs.btop}/bin/btop' },
          })
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
          mods = 'SUPER',
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
        -- Rename tab
        {
          key = "r",
          mods = "CMD",
          action = wezterm.action.PromptInputLine({
            description = "Enter new name for tab",
            action = wezterm.action_callback(function(window, _, line)
              if line then
                window:active_tab():set_title(line)
              end
            end),
          }),
        },
        { key = '-', mods = 'SUPER', action = wezterm.action.DecreaseFontSize },
        { key = '0', mods = 'SUPER', action = wezterm.action.ResetFontSize },
        { key = '=', mods = 'SUPER', action = wezterm.action.IncreaseFontSize },
        { key = 'c', mods = 'SUPER', action = wezterm.action.CopyTo('Clipboard') },
        { key = 'v', mods = 'SUPER', action = wezterm.action.PasteFrom('Clipboard') },
        { key = '[', mods = 'LEADER', action = wezterm.action.ActivateCopyMode },
        { key = 'p', mods = 'SUPER', action = wezterm.action.ActivateCommandPalette },
        { key = 'k', mods = 'SUPER', action = wezterm.action.ShowLauncherArgs {flags = "FUZZY|LAUNCH_MENU_ITEMS", title = "Command Palette"} },
      }

      config.ssh_domains = {
        {
          name = 'nixos-server',
          remote_address = 'nixos-server',
          username = 'mat',
        }
      }
      config.launch_menu = {
        {
          label = 'SSH to nixos-server',
          domain = { DomainName = 'nixos-server' },
          cwd = '~/git/dotfiles',
        }
      }

      smart_splits.apply_to_config(config)

      return config
    '';
  };
}
