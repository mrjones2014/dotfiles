local utils = require('lspconfig/util')

require('lspconfig').diagnosticls.setup({
  root_dir = utils.root_pattern('.git'),
  filetypes = { 'javascript', 'typescript', 'javascriptreact', 'typescriptreact', 'scss', 'css', 'bash', 'zsh', 'sh' },
  init_options = {
    filetypes = {
      javascript = 'eslint',
      typescript = 'eslint',
      javascriptreact = 'eslint',
      typescriptreact = 'eslint',
      scss = 'stylelint',
      css = 'stylelint',
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
    },
    linters = {
      eslint = {
        sourceName = 'eslint',
        command = 'eslint_d',
        rootPatterns = { '.git' },
        debounce = 100,
        args = {
          '--stdin',
          '--stdin-filename',
          '%filepath',
          '--format',
          'json',
        },
        parseJson = {
          errorsRoot = '[0].messages',
          line = 'line',
          column = 'column',
          endLine = 'endLine',
          endColumn = 'endColumn',
          message = '${message} [${ruleId}]',
          security = 'severity',
        },
        securities = {
          [2] = 'error',
          [1] = 'warning',
        },
      },
      stylelint = {
        command = './node_modules/.bin/stylelint',
        rootPatterns = { '.git' },
        debounce = 100,
        args = { '--formatter', 'json', '--stdin-filename', '%filepath' },
        sourceName = 'stylelint',
        parseJson = {
          errorsRoot = '[0].warnings',
          line = 'line',
          column = 'column',
          message = '${text}',
          security = 'severity',
        },
        securities = {
          error = 'error',
          warning = 'warning',
        },
      },
      shellcheck = {
        command = 'shellcheck',
        debounce = 100,
        args = { '--format', 'json', '-' },
        sourceName = 'shellcheck',
        parseJson = {
          line = 'line',
          column = 'column',
          endLine = 'endLine',
          endColumn = 'endColumn',
          message = '${message} [${code}]',
          security = 'level',
        },
        securities = {
          error = 'error',
          warning = 'warning',
          info = 'info',
          style = 'hint',
        },
      },
    },
    formatters = {
      prettier = {
        rootPatterns = { '.git' },
        command = './node_modules/.bin/prettier',
        args = { '--stdin-filepath', '%filepath' },
      },
    },
  },
})
