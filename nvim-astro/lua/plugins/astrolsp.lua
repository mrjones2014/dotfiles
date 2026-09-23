-- The language packs in lua/community.lua normally rely on mason-lspconfig to both
-- install *and* enable servers. Mason is disabled (see lua/plugins/mason.lua), so the
-- servers the packs don't register themselves are listed here. All of them come from
-- `programs.neovim.extraPackages` in home-manager/components/nvim.nix.

---@type LazySpec
return {
  'AstroNvim/astrolsp',
  dependencies = {
    -- merges .vscode/settings.json into LSP settings; wired up via
    -- `config['*'].before_init` below
    {
      'mrjones2014/codesettings.nvim',
      dev = true,
      cmd = 'Codesettings',
      ft = { 'json', 'jsonc', 'lua' },
    },
  },
  ---@type AstroLSPOpts
  opts = {
    features = {
      inlay_hints = true, -- AstroNvim defaults this off
    },
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
        -- which I don't prefer
        gK = false,
        gh = {
          function()
            vim.lsp.buf.signature_help()
          end,
          desc = 'Signature help',
          cond = 'textDocument/signatureHelp',
        },
        gI = false,
        gi = {
          function()
            vim.lsp.buf.implementation()
          end,
          desc = 'Implementation of current symbol',
          cond = 'textDocument/implementation',
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
