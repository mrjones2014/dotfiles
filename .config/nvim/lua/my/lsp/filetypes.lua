local M = {}

M.config = {
  ['css'] = {
    patterns = { '*.css', '*.scss' },
    lspconfig = 'cssls',
    mason = 'css-lsp',
  },
  ['html'] = {
    patterns = { '*.html' },
    lspconfig = 'html',
    mason = 'html-lsp',
  },
  ['json'] = {
    patterns = { '*.json', '*.jsonc' },
    lspconfig = 'jsonls',
    mason = 'json-lsp',
  },
  ['typescript'] = {
    patterns = { '*.ts', '*.tsx', '*.js', '*.jsx' },
    lspconfig = 'tsserver',
    mason = { 'typescript-language-server', 'prettier', 'prettierd', 'eslint_d' },
    treesitter = { 'javascript', 'typescript', 'tsx' },
  },
  ['lua'] = {
    patterns = { '*.lua' },
    lspconfig = 'lua_ls',
    mason = { 'lua-language-server', 'stylua', 'luacheck' },
    treesitter = { 'lua', 'luadoc' },
  },
  ['rust'] = {
    patterns = { '*.rs' },
    lspconfig = 'rust_analyzer',
    mason = { 'rust-analyzer', 'rustfmt' },
  },
  ['svelte'] = {
    patterns = { '*.svelte' },
    lspconfig = 'svelte',
    mason = 'svelte-language-server',
  },
  ['go'] = {
    patterns = { '*.go', 'go.mod' },
    lspconfig = 'gopls',
    mason = 'gopls',
  },
  ['markdown'] = {
    patterns = { '*.md', '*.markdown' },
    lspconfig = 'marksman',
    mason = { 'marksman', 'cbfmt', 'markdownlint' },
    treesitter = { 'markdown', 'markdown_inline' },
  },
  ['sh'] = {
    patterns = { '*.sh', '*.bash', '*.zsh' },
    mason = { 'shellcheck', 'shfmt' },
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
M.mason_packages = {}
M.treesitter_parsers = {}

for filetype, config in pairs(M.config) do
  -- mason package names
  if type(config.mason) == 'string' then
    table.insert(M.mason_packages, config.mason)
  elseif type(config.mason) == 'table' then
    table.insert_all(M.mason_packages, unpack(config.mason --[[@as table]]))
  end

  -- treesitter parser names
  if type(config.treesitter) == 'string' then
    table.insert(M.treesitter_parsers, config.treesitter)
  elseif type(config.treesitter) == 'table' then
    table.insert_all(M.treesitter_parsers, unpack(config.treesitter --[[@as table]]))
  else
    table.insert(M.treesitter_parsers, filetype)
  end
end

-- extras not associated with any one language
table.insert_all(M.mason_packages, 'codespell', 'lemmy-help', 'tree-sitter-cli')
table.insert_all(M.treesitter_parsers, 'comment', 'fish', 'gitcommit', 'vim', 'vimdoc', 'make', 'regex')

return M
