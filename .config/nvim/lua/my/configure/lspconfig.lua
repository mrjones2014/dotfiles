return {
  'neovim/nvim-lspconfig',
  requires = {
    'jose-elias-alvarez/null-ls.nvim',
    'j-hui/fidget.nvim',
    'rmagatti/goto-preview',
  },
  config = function()
    require('my.lsp')
  end,
}
