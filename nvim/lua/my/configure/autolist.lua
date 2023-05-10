return {
  'gaoDean/autolist.nvim',
  ft = 'markdown',
  config = function()
    local al = require('autolist')
    al.setup()
    al.create_mapping_hook('i', '<CR>', al.new)
    al.create_mapping_hook('i', '<Tab>', al.indent)
    al.create_mapping_hook('i', '<S-Tab>', al.indent, '<C-d>')
    al.create_mapping_hook('n', 'o', al.new)
    al.create_mapping_hook('n', 'O', al.new_before)
  end,
}
