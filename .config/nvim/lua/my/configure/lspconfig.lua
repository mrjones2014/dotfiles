return {
  'neovim/nvim-lspconfig',
  requires = {
    'jose-elias-alvarez/null-ls.nvim',
  },
  config = function()
    require('my.lsp')
  end,
}
