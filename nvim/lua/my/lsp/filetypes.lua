local M = {}

M.config = {
  ['css'] = {
    formatter = 'prettierd',
    lspconfig = { 'cssls' },
  },
  ['html'] = {
    lspconfig = { 'html' },
  },
  ['json'] = {
    lspconfig = 'jsonls',
    treesitter = { 'json', 'jsonc' },
  },
  ['typescript'] = {
    lspconfig = { 'ts_ls', 'eslint' },
    formatter = 'prettierd',
    treesitter = { 'typescript', 'javascript', 'tsx' },
  },
  ['lua'] = {
    lspconfig = 'lua_ls',
    formatter = 'stylua',
    linter = 'luacheck',
    treesitter = { 'lua', 'luadoc' },
  },
  ['rust'] = {
    -- let rustaceanvim set this up for us
    lspconfig = false,
    -- we just want auto formatting
    formatter = 'rustfmt',
  },
  ['go'] = {
    lspconfig = 'gopls',
    formatter = 'gofmt',
  },
  ['markdown'] = {
    lspconfig = 'marksman',
    formatter = {
      'prettierd',
      'injected', -- see :h conform-formatters, formats injected code blocks
    },
    treesitter = { 'markdown', 'markdown_inline' },
  },
  ['sh'] = {
    treesitter = { 'bash' },
    -- shellcheck and shellfmt are run through the LSP
    lspconfig = 'bashls',
  },
  ['swift'] = {
    lspconfig = 'sourcekit',
    formatter = 'swiftfmt',
    treesitter = false, -- requires treesitter-cli and only really works on mac
  },
  ['nix'] = {
    lspconfig = { 'nixd', 'nil_ls' },
    linter = 'statix',
    formatter = { 'nixpkgs_fmt', 'injected' },
  },
  ['toml'] = {
    lspconfig = 'taplo',
  },
  ['fish'] = {
    formatter = 'fish_indent',
    linter = 'fish',
  },
  ['yaml'] = {
    lspconfig = 'yamlls',
    treesitter = { 'yaml' },
  },
}

M.filetypes = vim.tbl_keys(M.config)

if vim.fn.filereadable('./tailwind.config.js') ~= 0 then
  table.insert(M.config['css'].lspconfig, 'tailwindcss')
  table.insert(M.config['typescript'].lspconfig, 'tailwindcss')
  table.insert(M.config['html'].lspconfig, 'tailwindcss')
end

-- these all use the same config
M.config['javascript'] = M.config['typescript']
M.config['typescriptreact'] = M.config['typescript']
M.config['javascriptreact'] = M.config['typescript']
M.config['scss'] = M.config['css']

local function cfg_by_ft(cfg)
  local result = {}
  for ft, ft_cfg in pairs(M.config) do
    if ft_cfg[cfg] then
      result[ft] = type(ft_cfg[cfg]) == 'table' and ft_cfg[cfg] or { ft_cfg[cfg] }
    end
  end
  return result
end

M.formatters_by_ft = cfg_by_ft('formatter')
M.linters_by_ft = cfg_by_ft('linter')

M.treesitter_parsers = (function()
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
  table.insert(result, 'just')
  table.insert(result, 'kdl')

  return result
end)()

return M
