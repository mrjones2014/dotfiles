local null_ls = require('null-ls')
local b = null_ls.builtins

local sources = {
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
}

if vim.fn.filereadable('./node_modules/.bin/stylelint') then
  table.insert(
    sources,
    b.formatting.stylelint.with({
      command = './node_modules/.bin/stylelint',
    })
  )
end

null_ls.config({
  sources = sources,
})

require('lspconfig')['null-ls'].setup({
  on_attach = require('modules.lsp-utils').on_attach,
})
