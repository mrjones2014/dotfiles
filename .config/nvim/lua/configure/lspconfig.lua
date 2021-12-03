return {
  'neovim/nvim-lspconfig',
  requires = {
    'ray-x/lsp_signature.nvim',
    'jose-elias-alvarez/null-ls.nvim',
  },
  config = function()
    require('lsp')
  end,
}
