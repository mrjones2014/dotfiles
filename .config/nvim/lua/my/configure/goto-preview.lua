return {
  'rmagatti/goto-preview',
  ft = require('my.lsp.filetypes').filetypes,
  config = function()
    require('goto-preview').setup({
      border = { '╭', '─', '╮', '│', '╯', '─', '╰', '│' },
    })
  end,
}
