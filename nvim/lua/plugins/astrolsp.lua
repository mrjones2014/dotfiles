---@type LazySpec
return {
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
          vim.lsp.buf.implementation,
          desc = 'Implementation of current symbol',
          cond = vim.lsp.protocol.Methods.textDocument_implementation,
        },
      },
    },
    config = {
      ['*'] = {
        before_init = function(_, config)
          -- merge .vscode/settings.json into LSP settings
          local ok, codesettings = pcall(require, 'codesettings')
          if ok then
            config = codesettings.with_local_settings(config.name, config)
          end
        end,
      },
    },
  },
}
