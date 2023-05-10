return {
  'echasnovski/mini.surround',
  keys = { '<leader>s' },
  config = function()
    require('mini.surround').setup({
      mappings = {
        add = '<leader>sa',
        delete = '<leader>sd',
        replace = '<leader>sr',
        find = '',
        find_left = '',
        highlight = '',
        update_n_lines = '',
      },
    })
  end,
}
