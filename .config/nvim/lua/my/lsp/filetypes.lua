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
    mason = 'rust-analyzer',
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
  ['csharp'] = {
    patterns = { '*.cs' },
    lspconfig = 'omnisharp',
    mason = 'omnisharp',
    treesitter = 'c_sharp',
  },
}

if vim.loop.os_uname().sysname == 'Darwin' then
  M.config['swift'] = {
    patterns = { '*.swift' },
    lspconfig = 'sourcekit',
    treesitter = 'swift',
  }
end

M.filetypes = vim.tbl_keys(M.config)

M.mason_packages = {}
M.treesitter_parsers = {}

for filetype, config in pairs(M.config) do
  -- mason package names
  if type(config.mason) == 'string' then
    table.insert(M.mason_packages, config.mason)
  elseif type(config.mason) == 'table' then
    for _, package in
      ipairs(config.mason --[[@as table]])
    do
      table.insert(M.mason_packages, package)
    end
  end

  -- treesitter parser names
  if type(config.treesitter) == 'string' then
    table.insert(M.treesitter_parsers, config.treesitter)
  elseif type(config.treesitter) == 'table' then
    table.insert_all(M.treesitter_parsers, config.treesitter)
  else
    table.insert(M.treesitter_parsers, filetype)
  end
end

-- extras not associated with any one language

table.insert(M.mason_packages, 'codespell')
table.insert(M.mason_packages, 'lemmy-help')

table.insert(M.treesitter_parsers, 'comment')
table.insert(M.treesitter_parsers, 'fish')
table.insert(M.treesitter_parsers, 'gitcommit')
table.insert(M.treesitter_parsers, 'vim')
table.insert(M.treesitter_parsers, 'vimdoc')
table.insert(M.treesitter_parsers, 'make')

return M
