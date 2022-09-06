return {
  'neovim/nvim-lspconfig',
  requires = {
    'jose-elias-alvarez/null-ls.nvim',
    'j-hui/fidget.nvim',
  },
  config = function()
    require('fidget').setup({
      text = {
        spinner = 'arc',
      },
    })
    require('my.lsp')
  end,
}
