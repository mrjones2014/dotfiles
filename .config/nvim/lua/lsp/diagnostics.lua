local utils = require('lspconfig/util')

require('lspconfig').diagnosticls.setup({
  root_dir = utils.root_pattern('.git'),
  filetypes = { 'javascript', 'typescript', 'javascriptreact', 'typescriptreact', 'scss', 'css', },
  init_options = {
    filetypes = {
      javascript = 'eslint',
      typescript = 'eslint',
      javascriptreact = 'eslint',
      typescriptreact = 'eslint',
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
        command = './node_modules/.bin/eslint',
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
          [1] = 'warning'
        },
      },
    },
    formatters = {
      prettier = {
        command = "./node_modules/.bin/prettier",
        args = {'--stdin-filepath', '%filepath'},
      },
    },
  },
})
