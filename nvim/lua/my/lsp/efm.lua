local efmls = require('efmls-configs')

local cbfmt = require('efmls-configs.formatters.cbfmt')
cbfmt.formatCommand =
  string.format('%s --config %s', cbfmt.formatCommand, string.format('%s/.config/cbfmt.toml', vim.env.HOME))

local node_config = {
  linter = require('efmls-configs.linters.eslint_d'),
  -- switch to prettier_d once I can figure out how to install it with Nix
  formatter = require('efmls-configs.formatters.prettier'),
}

local shell_config = {
  linter = require('efmls-configs.linters.shellcheck'),
  formatter = require('efmls-configs.formatters.shfmt'),
}

efmls.init({
  on_attach = require('my.lsp.utils').on_attach,
  init_options = {
    documentFormatting = true,
  },
})

efmls.setup({
  javascript = node_config,
  typescript = node_config,
  javascriptreact = node_config,
  typescriptreact = node_config,
  bash = shell_config,
  zsh = shell_config,
  sh = shell_config,
  lua = {
    linter = require('efmls-configs.linters.luacheck'),
    formatter = require('efmls-configs.formatters.stylua'),
  },
  nix = {
    linter = require('efmls-configs.linters.statix'),
    formatter = require('efmls-configs.formatters.nixfmt'),
  },
  markdown = {
    formatter = {
      require('efmls-configs.formatters.prettier'),
      cbfmt,
    },
  },
  fish = {
    formatter = require('efmls-configs.formatters.fish_indent'),
    linter = require('efmls-configs.linters.fish'),
  },
  go = {
    formatter = require('efmls-configs.formatters.gofmt'),
  },
  rust = {
    formatter = require('efmls-configs.formatters.rustfmt'),
  },
})
