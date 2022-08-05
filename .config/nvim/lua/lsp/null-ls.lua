local paths = require('paths')
local null_ls = require('null-ls')
local b = null_ls.builtins

local typescript_root_dir = nil
-- prioritize workspace roots
if
  vim.fn.filereadable(vim.loop.cwd() .. '/pnpm-workspace.yaml') > 0
  or vim.fn.filereadable(vim.loop.cwd() .. '/pnpm-workspace.yml') > 0
then
  typescript_root_dir = function()
    return vim.loop.cwd()
  end
end

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
    args = { '-I', paths.join(paths.config, 'codespell/custom_dict.txt'), '-' },
    filetypes = {
      'javascript',
      'typescript',
      'javascriptreact',
      'typescriptreact',
      'markdown',
      'text',
      'json',
      'jsonc',
      'css',
      'rust',
      'html',
    },
  }),

  -- formatting
  b.formatting.eslint_d,
  b.formatting.prettierd.with({
    filetypes = {
      'javascript',
      'typescript',
      'javascriptreact',
      'typescriptreact',
      'html',
      'json',
      'jsonc',
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
  b.formatting.gofmt,
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

local config = {
  sources = sources,
  on_attach = require('lsp.utils').on_attach,
  update_on_insert = true,
}

if typescript_root_dir ~= nil then
  config.root_dir = typescript_root_dir
end

null_ls.setup(config)
