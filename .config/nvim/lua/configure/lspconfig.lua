return {
  'neovim/nvim-lspconfig',
  requires = {
    'jose-elias-alvarez/null-ls.nvim',
    'nvim-lua/lsp_extensions.nvim',
  },
  config = function()
    require('lsp')
  end,
}
