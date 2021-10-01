local null_ls = require('null-ls')
local b = null_ls.builtins

null_ls.config({
  sources = {
    b.diagnostics.eslint.with({
      command = 'eslint_d',
    }),
    b.formatting.prettierd.with({
      filetypes = {
        'html',
        'json',
        'javascript',
        'typescript',
        'javascriptreact',
        'typescriptreact',
        'scss',
        'css',
      },
    }),
    b.formatting.stylua,
    b.diagnostics.luacheck,
    b.formatting.shfmt,
    b.diagnostics.shellcheck.with({
      diagnostics_format = '#{m} [#{s}] [#{c}]',
    }),
    -- stylelint is not built-in
    {
      name = 'stylelint',
      method = null_ls.methods.DIAGNOSTICS,
      filetypes = { 'scss', 'sass', 'css' },
      generator = null_ls.generator({
        command = './node_modules/.bin/stylelint',
        args = { '--formatter', 'json', '--stdin-filename', '%filepath' },
        format = 'json',
        check_exit_code = function(code)
          return code == 0
        end,
        on_output = function(params)
          print(vim.inspect(params))
          --[[ local parser = require('null-ls.helpers').diagnostics.from_json({
            attributes = {},
          })

          return parser({ output = params.output }) ]]
        end,
      }),
    },
  },
})

require('lspconfig')['null-ls'].setup({
  on_attach = require('modules.lsp-utils').on_attach,
})
