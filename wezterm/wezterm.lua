local w = require('wezterm')
local keymaps = require('keymaps')

local os_name
if w.target_triple == 'x86_64-apple-darwin' or w.target_triple == 'aarch64-apple-darwin' then
  os_name = 'macOS'
else
  os_name = 'linux'
end

local config = w.config_builder()
config.color_scheme_dirs = { '~/.config/wezterm/colors/' }
config.color_scheme = 'onedarkpro_onedark_dark'
config.cursor_blink_rate = 0
config.font = w.font('FiraCode Nerd Font')
config.font_size = 14
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

config.leader = keymaps.leader
config.keys = keymaps.keys
-- behaves weirdly on linux
config.hide_mouse_cursor_when_typing = os_name == 'macOS'
config.enable_wayland = false

if os_name == 'macOS' then
  config.window_decorations = 'RESIZE'
end

return config
