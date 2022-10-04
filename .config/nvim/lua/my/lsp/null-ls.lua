local paths = require('my.paths')
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

local function has_local_stylelint()
  return vim.fn.filereadable('./node_modules/.bin/stylelint') ~= 0
end

local code_actions = {
  b.code_actions.gitsigns,
  b.code_actions.eslint_d,
  b.code_actions.shellcheck,
}

local diagnostics = {
  b.diagnostics.eslint_d,
  b.diagnostics.stylelint.with({
    command = './node_modules/.bin/stylelint',
    condition = has_local_stylelint,
  }),
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
}

local formatters = {
  b.formatting.eslint_d,
  b.formatting.stylelint.with({
    command = './node_modules/.bin/stylelint',
    condition = has_local_stylelint,
  }),
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
  b.formatting.rustfmt.with({
    -- read Rust edition from Cargo.toml
    extra_args = function(params)
      local Path = require('plenary.path')
      local cargo_toml = Path:new(params.root .. '/' .. 'Cargo.toml')

      if cargo_toml:exists() and cargo_toml:is_file() then
        for _, line in ipairs(cargo_toml:readlines()) do
          local edition = line:match([[^edition%s*=%s*%"(%d+)%"]])
          if edition then
            return { '--edition=' .. edition }
          end
        end
      end
      -- default edition when we don't find `Cargo.toml` or the `edition` in it.
      return { '--edition=2021' }
    end,
  }),
  b.formatting.stylua,
  b.formatting.shfmt.with({
    filetypes = { 'sh', 'zsh', 'bash' },
    args = { '-i', '2' },
  }),
  b.formatting.fish_indent,
  b.formatting.gofmt,
}

local config = {
  sources = require('my.utils').join_lists(code_actions, diagnostics, formatters),
  on_attach = require('my.lsp.utils').on_attach,
}

if typescript_root_dir ~= nil then
  config.root_dir = typescript_root_dir
end

null_ls.setup(config)
