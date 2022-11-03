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
    mason = { 'typescript-language-server', 'prettierd', 'eslint_d' },
  },
  ['lua'] = {
    patterns = { '*.lua' },
    lspconfig = 'sumneko_lua',
    mason = { 'lua-language-server', 'stylua', 'luacheck' },
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
  ['teal'] = {
    patterns = { '*.tl', '*.d.tl' },
    lspconfig = 'teal_ls',
    mason = 'teal-language-server',
  },
  ['go'] = {
    patterns = { '*.go', 'go.mod' },
    lspconfig = 'gopls',
    mason = 'gopls',
  },
  ['markdown'] = {
    patterns = { '*.md', '*.markdown' },
    lspconfig = 'marksman',
    mason = 'marksman',
  },
  ['sh'] = {
    patterns = { '*.sh', '*.bash', '*.zsh' },
    mason = { 'shellcheck', 'shfmt' },
  },
}

M.filetypes = vim.tbl_keys(M.config)

M.mason_packages = {}

vim.tbl_map(function(config)
  if type(config.mason) == 'string' then
    table.insert(M.mason_packages, config.mason)
  else
    for _, package in ipairs(config.mason) do
      table.insert(M.mason_packages, package)
    end
  end
end, vim.tbl_values(M.config))

-- extras not associated with any one language
table.insert(M.mason_packages, 'codespell')

return M
