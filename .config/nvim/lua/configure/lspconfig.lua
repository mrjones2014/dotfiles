return {
  'neovim/nvim-lspconfig',
  requires = {
    'ray-x/lsp_signature.nvim',
    'jose-elias-alvarez/null-ls.nvim',
    'filipdutescu/renamer.nvim',
  },
  config = function()
    require('lsp')
    require('renamer').setup()
  end,
}
