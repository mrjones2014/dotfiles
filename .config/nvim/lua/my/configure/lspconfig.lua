return {
  'neovim/nvim-lspconfig',
  requires = {
    'jose-elias-alvarez/null-ls.nvim',
    'j-hui/fidget.nvim',
    'rmagatti/goto-preview',
  },
  config = function()
    require('fidget').setup({
      text = {
        spinner = 'arc',
      },
    })
    require('goto-preview').setup({
      border = { '╭', '─', '╮', '│', '╯', '─', '╰', '│' },
    })
    require('my.lsp')
  end,
}
