---@type LazySpec
return {
  'nvim-mini/mini.move',
  keys = {
    { 'J', desc = 'Move text down', mode = { 'n', 'x' } },
    { 'K', desc = 'Move text up', mode = { 'n', 'x' } },
  },
  opts = {
    mappings = {
      -- visual mode
      down = 'J',
      up = 'K',
      -- normal mode, linewise
      line_down = 'J',
      line_up = 'K',
      -- I don't use the horizontal moves
      left = '',
      right = '',
      line_left = '',
      line_right = '',
    },
  },
}
