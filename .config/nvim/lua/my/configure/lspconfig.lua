return {
  'neovim/nvim-lspconfig',
  requires = {
    'jose-elias-alvarez/null-ls.nvim',
    'j-hui/fidget.nvim',
    'rmagatti/goto-preview',
    'williamboman/mason.nvim',
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    'hrsh7th/cmp-nvim-lsp',
  },
  config = function()
    require('mason').setup()
    require('mason-tool-installer').setup({
      auto_update = true,
      ensure_installed = vim.tbl_map(function(config)
        return config.mason
      end, require('my.lsp.filetypes').config),
    })
    require('my.lsp').setup()
  end,
}
