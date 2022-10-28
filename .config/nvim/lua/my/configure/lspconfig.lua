return {
  'neovim/nvim-lspconfig',
  requires = {
    'jose-elias-alvarez/null-ls.nvim',
    'rmagatti/goto-preview',
    'williamboman/mason.nvim',
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    'hrsh7th/cmp-nvim-lsp',
  },
  config = function()
    require('mason').setup()
    require('mason-tool-installer').setup({
      auto_update = true,
      ensure_installed = require('my.lsp.filetypes').mason_packages,
    })
    require('my.lsp').setup()
  end,
}
