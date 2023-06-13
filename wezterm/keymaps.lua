local w = require('wezterm')

local function is_vim(pane)
  return pane:get_user_vars().IS_NVIM == 'true'
end

local direction_keys = {
  Left = 'h',
  Down = 'j',
  Up = 'k',
  Right = 'l',
  -- reverse lookup
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

return {
  -- simulate tmux prefix with leader
  leader = { key = 'b', mods = 'CTRL', timeout_milliseconds = 1000 },
  keys = {
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
      action = w.action.SpawnTab('DefaultDomain'),
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
  },
}
