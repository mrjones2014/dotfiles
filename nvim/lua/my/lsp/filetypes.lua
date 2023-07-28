local M = {}

M.config = {
  ['css'] = {
    patterns = { '*.css', '*.scss' },
    lspconfig = 'cssls',
  },
  ['html'] = {
    lspconfig = 'html',
  },
  ['json'] = {
    patterns = { '*.json', '*.jsonc' },
    lspconfig = 'jsonls',
  },
  ['typescript'] = {
    patterns = { '*.ts', '*.tsx', '*.js', '*.jsx' },
    lspconfig = 'tsserver',
    formatter = 'prettier',
    linter = 'eslint_d',
  },
  ['lua'] = {
    lspconfig = 'lua_ls',
    formatter = 'stylua',
    linter = 'luacheck',
  },
  ['rust'] = {
    patterns = { '*.rs' },
    lspconfig = 'rust_analyzer',
    formatter = 'rustfmt',
  },
  ['go'] = {
    patterns = { '*.go', 'go.mod' },
    lspconfig = 'gopls',
    formatter = 'gofmt',
  },
  ['markdown'] = {
    patterns = { '*.md', '*.markdown' },
    lspconfig = 'marksman',
    formatter = {
      'prettier',
      'cbfmt',
    },
  },
  ['sh'] = {
    patterns = { '*.sh', '*.bash', '*.zsh' },
    linter = 'shellcheck',
    formatter = 'shfmt',
  },
  ['swift'] = {
    lspconfig = 'sourcekit',
  },
  ['nix'] = {
    lspconfig = 'rnix',
    linter = 'statix',
    formatter = 'nixfmt',
  },
  ['toml'] = {
    lspconfig = 'taplo',
  },
  ['fish'] = {
    formatter = 'fish_indent',
  },
}
-- these all use the same config
M.config['javascript'] = M.config['typescript']
M.config['typescriptreact'] = M.config['typescript']
M.config['javascriptreact'] = M.config['typescript']

M.filetypes = vim.tbl_keys(M.config)

local efm_customizations = {
  ['cbfmt'] = function()
    local cbfmt = require('efmls-configs.formatters.cbfmt')
    cbfmt.formatCommand =
      string.format('%s --config %s', cbfmt.formatCommand, string.format('%s/.config/cbfmt.toml', vim.env.HOME))
    return cbfmt
  end,
}

local function load_efm_modules(mods, mod_type)
  if not mods then
    return nil
  end

  if type(mods) == 'string' then
    return require(string.format('efmls-configs.%s.%s', mod_type, mods))
  else
    return vim.tbl_map(function(mod)
      if efm_customizations[mod] then
        return efm_customizations[mod]()
      end

      return require(string.format('efmls-configs.%s.%s', mod_type, mod))
    end, mods)
  end
end

local function load_linters(linters)
  return load_efm_modules(linters, 'linters')
end

local function load_formatters(formatters)
  return load_efm_modules(formatters, 'formatters')
end

function M.efmls_config()
  local result = {}
  for filetype, config in pairs(M.config) do
    if config.linter or config.formatter then
      result[filetype] = {
        formatter = load_formatters(config.formatter),
        linter = load_linters(config.linter),
      }
    end
  end

  return result
end

return M
