local null_ls = require('null-ls')
local b = null_ls.builtins

local sources = {
  -- code actions
  b.code_actions.gitsigns,

  -- diagnostics
  b.diagnostics.eslint_d,
  b.diagnostics.luacheck,
  b.diagnostics.shellcheck.with({
    diagnostics_format = '#{m} [#{s}] [#{c}]',
  }),

  -- formatting
  b.formatting.eslint_d,
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
  b.formatting.rustfmt,
  b.formatting.stylua,
  b.formatting.shfmt.with({
    filetypes = { 'sh', 'zsh', 'bash' },
    args = { '-i', '2' },
  }),
  b.formatting.fish_indent,
}

if vim.fn.filereadable('./node_modules/.bin/stylelint') > 0 then
  table.insert(
    sources,
    b.formatting.stylelint.with({
      command = './node_modules/.bin/stylelint',
    })
  )
  table.insert(
    sources,
    b.diagnostics.stylelint.with({
      command = './node_modules/.bin/stylelint',
    })
  )
end

null_ls.config({
  sources = sources,
})

require('lspconfig')['null-ls'].setup({
  on_attach = require('lsp.utils').on_attach,
})
