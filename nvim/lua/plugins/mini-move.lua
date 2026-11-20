---@type LazySpec
return {
  -- the pack derives lazy `keys` from `opts.mappings`, skipping empty ones
  { import = 'astrocommunity.motion.mini-move' },
  {
    'echasnovski/mini.move',
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
  },
}
