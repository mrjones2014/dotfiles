local M = {}

M.config = {
  json = {
    treesitter = { 'json', 'jsonc' },
  },
  typescript = {
    formatter = 'prettierd',
    treesitter = { 'typescript', 'javascript', 'tsx' },
  },
  lua = {
    formatter = 'stylua',
    linter = 'luacheck',
    treesitter = { 'lua', 'luadoc' },
  },
  rust = {
    formatter = 'rustfmt',
  },
  go = {
    formatter = 'gofmt',
  },
  markdown = {
    formatter = {
      'prettierd',
      'injected', -- see :h conform-formatters, formats injected code blocks
    },
    treesitter = { 'markdown', 'markdown_inline' },
  },
  sh = {
    treesitter = { 'bash' },
  },
  swift = {
    formatter = 'swiftfmt',
    treesitter = false, -- requires treesitter-cli and only really works on mac
  },
  nix = {
    linter = 'statix',
    formatter = { 'nixfmt', 'injected' },
  },
  fish = {
    formatter = 'fish_indent',
    linter = 'fish',
  },
  yaml = {
    treesitter = { 'yaml' },
    formatter = { 'yamlfmt' },
  },
  vim = {
    treesitter = { 'vim' },
  },
  graphql = {
    treesitter = { 'graphql', 'http' },
  },
}

M.filetypes = vim.tbl_keys(M.config)

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
