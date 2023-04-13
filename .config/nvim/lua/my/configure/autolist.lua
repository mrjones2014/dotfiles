return {
  'gaoDean/autolist.nvim',
  ft = { 'markdown', 'text' },
  config = function()
    local al = require('autolist')
    al.setup()
    al.create_mapping_hook('i', '<CR>', al.new)
    al.create_mapping_hook('i', '<Tab>', al.indent)
    al.create_mapping_hook('i', '<S-Tab>', al.indent, '<C-d>')
  end,
}
