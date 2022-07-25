return {
  'neovim/nvim-lspconfig',
  requires = {
    'jose-elias-alvarez/null-ls.nvim',
    'https://git.sr.ht/~whynothugo/lsp_lines.nvim',
  },
  config = function()
    require('lsp')
  end,
}
