local w = require('wezterm')
local keymaps = require('keymaps')

return {
  window_decorations = 'RESIZE',
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
