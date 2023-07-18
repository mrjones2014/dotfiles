local js_fmt = {
  fmt = {
    cmd = 'prettier_d_slim',
    args = { '--stdin-filepath' },
    fname = true,
    stdin = true,
  },
}

local shell_fmt = {
  fmt = {
    cmd = 'shfmt',
    args = { '-i', '2', '--filename' },
    fname = true,
    stdin = true,
  },
}

local ft_settings = {
  javascript = js_fmt,
  typescript = js_fmt,
  javascriptreact = js_fmt,
  typescriptreact = js_fmt,
  json = js_fmt,
  sh = shell_fmt,
  bash = shell_fmt,
  zsh = shell_fmt,
  fish = {
    fmt = {
      cmd = 'fish_indent',
      fname = true,
    },
  },
  rust = {
    fmt = { 'rustfmt' },
  },
  markdown = {
    fmt = {
      cmd = 'markdownlint',
      args = { '--fix' },
      fname = true,
    },
  },
  lua = {
    fmt = { 'stylua' },
  },
  fish_indent = { -- doesn't work
    fmt = {
      cmd = 'fish_indent',
      fname = true,
    },
  },
  go = { -- doesn't work
    fmt = {
      cmd = 'gofmt',
      fname = true,
    },
  },
  nix = { -- doesn't work
    fmt = {
      cmd = 'nixfmt',
      fname = true,
    },
  },
}

return {
  'nvimdev/guard.nvim',
  ft = vim.tbl_keys(ft_settings),
  opts = {
    fmt_on_save = true,
    ft = ft_settings,
  },
}
