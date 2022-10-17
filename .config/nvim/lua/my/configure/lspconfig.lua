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
      ensure_installed = {
        -- LSP servers
        'css-lsp',
        'html-lsp',
        'json-lsp',
        'typescript-language-server',
        'rust-analyzer',
        'svelte-language-server',
        'gopls',
        'lua-language-server',
        'teal-language-server',

        -- linters
        'eslint_d',
        'shellcheck',
        'luacheck',
        'codespell',

        -- formatters
        'prettierd',
        'stylua',
        'shfmt',
      },
    })
    require('my.lsp')
  end,
}
