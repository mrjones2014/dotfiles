return {
  {
    'mrjones2014/mdpreview.nvim',
    dev = true,
    ft = 'markdown',
    dependencies = { 'norcalli/nvim-terminal.lua', config = true },
  },
  {
    'gaoDean/autolist.nvim',
    ft = 'markdown',
    version = '2.3.0',
    config = function()
      local al = require('autolist')
      al.setup()
      al.create_mapping_hook('i', '<CR>', al.new)
      al.create_mapping_hook('i', '<Tab>', al.indent)
      al.create_mapping_hook('i', '<S-Tab>', al.indent, '<C-d>')
      al.create_mapping_hook('n', 'o', al.new)
      al.create_mapping_hook('n', 'O', al.new_before)
    end,
  },
}
