local M = {}

M.config = {
  ['css'] = {
    patterns = { '*.css', '*.scss' },
    lspconfig = 'cssls',
  },
  ['html'] = {
    patterns = { '*.html' },
    lspconfig = 'html',
  },
  ['json'] = {
    patterns = { '*.json', '*.jsonc' },
    lspconfig = 'jsonls',
  },
  ['typescript'] = {
    patterns = { '*.ts', '*.tsx', '*.js', '*.jsx' },
    lspconfig = 'tsserver',
    treesitter = { 'javascript', 'typescript', 'tsx' },
  },
  ['lua'] = {
    patterns = { '*.lua' },
    lspconfig = 'lua_ls',
    treesitter = { 'lua', 'luadoc' },
  },
  ['rust'] = {
    patterns = { '*.rs' },
    lspconfig = 'rust_analyzer',
  },
  ['svelte'] = {
    patterns = { '*.svelte' },
    lspconfig = 'svelte',
  },
  ['go'] = {
    patterns = { '*.go', 'go.mod' },
    lspconfig = 'gopls',
  },
  ['markdown'] = {
    patterns = { '*.md', '*.markdown' },
    lspconfig = 'marksman',
    treesitter = { 'markdown', 'markdown_inline' },
  },
  ['sh'] = {
    patterns = { '*.sh', '*.bash', '*.zsh' },
    treesitter = 'bash',
  },
  ['swift'] = {
    patterns = { '*.swift' },
    lspconfig = 'sourcekit',
    treesitter = 'swift',
  },
  ['nix'] = {
    lspconfig = 'rnix',
    treesitter = 'nix',
  },
}

M.filetypes = vim.tbl_keys(M.config)
M.treesitter_parsers = {}

for filetype, config in pairs(M.config) do
  -- treesitter parser names
  if type(config.treesitter) == 'string' then
    table.insert(M.treesitter_parsers, config.treesitter)
  elseif type(config.treesitter) == 'table' then
    M.treesitter_parsers = TblUtils.join_lists(M.treesitter_parsers, config.treesitter --[[@as table]])
  else
    table.insert(M.treesitter_parsers, filetype)
  end
end

-- extras not associated with any one language
M.treesitter_parsers =
  TblUtils.join_lists(M.treesitter_parsers, { 'comment', 'fish', 'gitcommit', 'vim', 'vimdoc', 'make', 'regex' })

return M
