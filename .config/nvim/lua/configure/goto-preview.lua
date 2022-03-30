return {
  'rmagatti/goto-preview',
  ft = require('lsp.filetypes').filetypes,
  config = function()
    require('goto-preview').setup({
      border = { '╭', '─', '╮', '│', '╯', '─', '╰', '│' },
    })
  end,
}
