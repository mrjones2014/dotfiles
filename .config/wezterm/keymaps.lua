local w = require('wezterm')

-- Equivalent to POSIX basename(3)
-- Given "/foo/bar" returns "bar"
-- Given "c:\\foo\\bar" returns "bar"
local function basename(s)
  return string.gsub(s, '(.*[/\\])(.*)', '%2')
end

local function is_vim(pane)
  local process_name = basename(pane:get_foreground_process_name())
  return process_name == 'nvim' or process_name == 'vim'
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

local scratchpad_panes = {}

-- simulate tmux prefix with leader
return {
  leader = { key = 'b', mods = 'CTRL', timeout_milliseconds = 1000 },
  keys = {
    -- create split panes
    {
      key = '\\',
      mods = 'LEADER',
      action = w.action.SplitHorizontal({ domain = 'CurrentPaneDomain' }),
    },
    {
      key = '-',
      mods = 'LEADER',
      action = w.action.SplitVertical({ domain = 'CurrentPaneDomain' }),
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
      action = w.action_callback(function(win)
        win:mux_window():spawn_tab({ cwd = '~' })
      end),
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
    {
      key = 't',
      mods = 'META',
      action = w.action_callback(function(win, pane)
        for idx, id in ipairs(scratchpad_panes) do
          if pane:pane_id() == id then
            win:perform_action({ CloseCurrentPane = { confirm = false } }, pane)
            table.remove(scratchpad_panes, idx)
            return
          end
        end

        local new_pane = pane:split({ direction = 'Bottom' })
        new_pane:tab():set_zoomed(true)
        table.insert(scratchpad_panes, new_pane:pane_id())
      end),
    },
  },
}
