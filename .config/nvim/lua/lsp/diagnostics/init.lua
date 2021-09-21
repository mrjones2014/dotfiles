local utils = require('lspconfig/util')

require('lspconfig').diagnosticls.setup({
  root_dir = utils.root_pattern('.git', '.luacheckrc'),
  filetypes = {
    'javascript',
    'typescript',
    'javascriptreact',
    'typescriptreact',
    'scss',
    'css',
    'lua',
    'bash',
    'zsh',
    'sh',
  },
  handlers = {
    ['textDocument/publishDiagnostics'] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
      update_in_insert = true,
    }),
  },
  init_options = {
    filetypes = {
      javascript = 'eslint',
      typescript = 'eslint',
      javascriptreact = 'eslint',
      typescriptreact = 'eslint',
      scss = 'stylelint',
      css = 'stylelint',
      lua = 'luacheck',
      bash = 'shellcheck',
      zsh = 'shellcheck',
      sh = 'shellcheck',
    },
    formatFiletypes = {
      typescript = 'prettier',
      typescriptreact = 'prettier',
      javascript = 'prettier',
      javascriptreact = 'prettier',
      css = 'prettier',
      scss = 'prettier',
      lua = 'stylua',
    },
    linters = {
      eslint = require('lsp.diagnostics.eslint'),
      stylelint = require('lsp.diagnostics.stylelint'),
      shellcheck = require('lsp.diagnostics.shellcheck'),
      luacheck = require('lsp.diagnostics.luacheck'),
    },
    formatters = {
      prettier = require('lsp.diagnostics.prettier'),
      stylua = require('lsp.diagnostics.stylua'),
    },
  },
})
