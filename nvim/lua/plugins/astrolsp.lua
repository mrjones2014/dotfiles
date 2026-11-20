---@type LazySpec
return {
  { import = 'astrocommunity.recipes.picker-lsp-mappings' },
  {
    'AstroNvim/astrolsp',
    dependencies = {
      {
        'mrjones2014/codesettings.nvim',
        lazy = true,
        dev = true,
        cmd = 'Codesettings',
        ft = { 'json', 'jsonc', 'lua' },
      },
    },
    ---@type AstroLSPOpts
    opts = {
      features = {
        inlay_hints = true,
        codelens = false,
      },
      config = {
        ['*'] = {
          before_init = function(_, config)
            require('codesettings').with_local_settings(config.name, config)
          end,
        },
      },
      -- list servers manually since I don't use mason/mason-lspconfig
      servers = {
        'ast_grep',
        'bashls',
        'clangd',
        'gopls',
        'graphql',
        'jsonls',
        'just',
        'lua_ls',
        'marksman',
        'nil_ls',
        'nixd',
        'tombi',
        'ts_ls',
        'yamlls',
      },
      mappings = {
        n = {
          -- AstroNvim puts signature help on gK and implementation on gI,
          -- which I don't prefer. Hover moves off of K (Neovim's LSP default)
          -- to gh so that K is free for mini.move (see plugins/mini-move.lua).
          gK = false,
          gh = {
            vim.lsp.buf.hover,
            desc = 'Show LSP hover menu',
            cond = vim.lsp.protocol.Methods.textDocument_hover,
          },
          gs = {
            vim.lsp.buf.signature_help,
            desc = 'Signature help',
            cond = vim.lsp.protocol.Methods.textDocument_signatureHelp,
          },
          gI = false,
          gi = {
            function()
              require('snacks.picker').lsp_implementations()
            end,
            desc = 'Implementation of current symbol',
            cond = vim.lsp.protocol.Methods.textDocument_implementation,
          },
        },
      },
    },
  },
}
