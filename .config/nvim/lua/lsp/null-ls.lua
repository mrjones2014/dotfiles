local null_ls = require('null-ls')
local b = null_ls.builtins

local sources = {
  -- code actions
  b.code_actions.gitsigns,
  b.code_actions.eslint_d,
  b.code_actions.shellcheck,

  -- diagnostics
  b.diagnostics.eslint_d,
  b.diagnostics.luacheck,
  b.diagnostics.shellcheck.with({
    diagnostics_format = '#{m} [#{s}] [#{c}]',
  }),
  b.diagnostics.codespell.with({
    filetypes = {
      'markdown',
      'text',
    },
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
      'markdown',
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

null_ls.setup({
  sources = sources,
  on_attach = require('lsp.utils').on_attach,
  update_on_insert = true,
})
