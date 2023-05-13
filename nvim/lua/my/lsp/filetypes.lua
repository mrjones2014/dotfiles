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
  },
  ['lua'] = {
    patterns = { '*.lua' },
    lspconfig = 'lua_ls',
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
  },
  ['sh'] = {
    patterns = { '*.sh', '*.bash', '*.zsh' },
  },
  ['swift'] = {
    patterns = { '*.swift' },
    lspconfig = 'sourcekit',
  },
  ['nix'] = {
    lspconfig = 'rnix',
  },
}

M.filetypes = vim.tbl_keys(M.config)

return M
