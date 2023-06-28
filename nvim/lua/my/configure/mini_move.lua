return {
  'echasnovski/mini.move',
  keys = {
    { '<S-h>', desc = 'Move text left', mode = { 'n', 'v', 'x' } },
    { '<S-l>', desc = 'Move text right', mode = { 'n', 'v', 'x' } },
    { '<S-j>', desc = 'Move text down', mode = { 'n', 'v', 'x' } },
    { '<S-k>', desc = 'Move text up', mode = { 'n', 'v', 'x' } },
  },
  opts = {
    mappings = {
      left = '<S-h>',
      right = '<S-l>',
      up = '<S-k>',
      down = '<S-j>',
      line_left = '<S-h>',
      line_right = '<S-l>',
      line_up = '<S-k>',
      line_down = '<S-j>',
    },
  },
}
