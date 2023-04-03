local w = require('wezterm')
local keymaps = require('keymaps')

local os_name
if w.target_triple == 'x86_64-apple-darwin' or w.target_triple == 'aarch64-apple-darwin' then
  os_name = 'macOS'
else
  os_name = 'linux'
end

local config = {
  color_scheme = 'OneHalfBlack (Gogh)',
  cursor_blink_rate = 0,
  font = w.font('FiraCode Nerd Font'),
  font_size = 14,
  use_fancy_tab_bar = true,
  tab_bar_at_bottom = true,
  hide_tab_bar_if_only_one_tab = true,
  window_padding = {
    top = 0,
    bottom = 0,
    left = 0,
    right = 0,
  },
  debug_key_events = true,
  leader = keymaps.leader,
  keys = keymaps.keys,
}

if os_name == 'macOS' then
  config.window_decorations = 'RESIZE'
end

return config
