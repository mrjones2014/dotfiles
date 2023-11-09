local M = {}

M.config = {
  ['css'] = {
    patterns = { '*.css', '*.scss' },
    lspconfig = { 'cssls' },
  },
  ['html'] = {
    lspconfig = { 'html' },
  },
  ['json'] = {
    patterns = { '*.json', '*.jsonc' },
    lspconfig = 'jsonls',
    treesitter = { 'json', 'jsonc' },
  },
  ['typescript'] = {
    patterns = { '*.ts', '*.tsx', '*.js', '*.jsx' },
    lspconfig = { 'tsserver', 'eslint' },
    formatter = 'prettier_d',
    treesitter = { 'typescript', 'javascript', 'tsx' },
  },
  ['lua'] = {
    lspconfig = 'lua_ls',
    formatter = 'stylua',
    linter = 'luacheck',
    treesitter = { 'lua', 'luadoc' },
  },
  ['rust'] = {
    patterns = { '*.rs' },
    lspconfig = 'rust_analyzer',
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
      'prettier_d',
      'cbfmt',
    },
    treesitter = { 'markdown', 'markdown_inline' },
  },
  ['sh'] = {
    patterns = { '*.sh', '*.bash', '*.zsh' },
    linter = 'shellcheck',
    formatter = 'shfmt',
    treesitter = { 'bash' },
  },
  ['swift'] = {
    lspconfig = 'sourcekit',
    treesitter = false, -- requires treesitter-cli and only really works on mac
  },
  ['nix'] = {
    lspconfig = 'nil_ls',
    linter = 'statix',
    formatter = 'nixfmt',
  },
  ['toml'] = {
    lspconfig = 'taplo',
  },
  ['fish'] = {
    formatter = 'fish_indent',
    linter = 'fish',
  },
}

M.filetypes = vim.tbl_keys(M.config)

if vim.fn.filereadable('./tailwind.config.js') then
  table.insert(M.config['css'].lspconfig, 'tailwindcss')
  table.insert(M.config['typescript'].lspconfig, 'tailwindcss')
  table.insert(M.config['html'].lspconfig, 'tailwindcss')
end

-- these all use the same config
M.config['javascript'] = M.config['typescript']
M.config['typescriptreact'] = M.config['typescript']
M.config['javascriptreact'] = M.config['typescript']

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

  -- normalize type to string[]
  mods = type(mods) == 'string' and { mods } or mods
  return vim.tbl_map(function(mod)
    if efm_customizations[mod] then
      return efm_customizations[mod]()
    end

    local ok, module = pcall(require, string.format('efmls-configs.%s.%s', mod_type, mod))
    if not ok then
      vim.notify(string.format('Module efmls-configs.%s.%s not found', mod_type, mod))
      return nil
    end
    return module
  end, mods)
end

local function load_linters(linters)
  return load_efm_modules(linters, 'linters') or {}
end

local function load_formatters(formatters)
  return load_efm_modules(formatters, 'formatters') or {}
end

function M.efmls_config(capabilities)
  local languages = {}
  for filetype, config in pairs(M.config) do
    if config.linter or config.formatter then
      languages[filetype] = vim.list_extend(load_formatters(config.formatter), load_linters(config.linter))
    end
  end

  return {
    filetypes = vim.tbl_keys(languages),
    settings = { languages = languages },
    init_options = {
      documentFormatting = true,
      documentRangeFormatting = true,
    },
    capabilities = capabilities,
  }
end

function M.uses_efm(ft)
  ft = ft or vim.bo.ft
  return vim.tbl_get(M.config, ft, 'formatter') ~= nil or vim.tbl_get(M.config, ft, 'linter') ~= nil
end

function M.formats_with_efm(ft)
  ft = ft or vim.bo.ft
  return vim.tbl_get(M.config, ft, 'formatter') ~= nil
end

function M.treesitter_parsers()
  local result = {}
  for ft, config in pairs(M.config) do
    if config.treesitter ~= false then
      local treesitter = config.treesitter or ft
      treesitter = type(treesitter) == 'table' and treesitter or { treesitter }
      result = vim.list_extend(result, treesitter)
    end
  end

  -- insert extra parsers here
  table.insert(result, 'regex')

  return result
end

return M
