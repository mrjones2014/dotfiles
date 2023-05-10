local null_ls = require('null-ls')
local b = null_ls.builtins

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
    args = { '-I', Path.join(vim.env.HOME, '.config', 'codespell/custom_dict.txt'), '-' },
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
    },
  }),
  b.formatting.markdownlint,
  b.formatting.cbfmt.with({
    args = {
      '--stdin-filepath',
      '$FILENAME',
      '--best-effort',
      '--config',
      string.format('%s/.config/cbfmt.toml', vim.env.HOME),
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
  b.formatting.swiftformat,
  b.formatting.nixfmt,
}

local config = {
  sources = TblUtils.join_lists(code_actions, diagnostics, formatters),
  -- add `.luacheckrc` as a root pattern
  root_dir = require('null-ls.utils').root_pattern('.null-ls-root', 'Makefile', '.git', '.luacheckrc'),
}

null_ls.setup(config)
