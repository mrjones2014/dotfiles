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
  },
  ['lua'] = {
    lspconfig = 'lua_ls',
  },
  ['rust'] = {
    patterns = { '*.rs' },
    lspconfig = 'rust_analyzer',
  },
  ['svelte'] = {
    lspconfig = 'svelte',
  },
  ['go'] = {
    patterns = { '*.go', 'go.mod' },
    lspconfig = 'gopls',
  },
  ['markdown'] = {
    lspconfig = 'marksman',
  },
  ['sh'] = {
    patterns = { '*.sh', '*.bash', '*.zsh' },
  },
  ['swift'] = {
    lspconfig = 'sourcekit',
  },
  ['nix'] = {
    lspconfig = 'rnix',
  },
  ['toml'] = {
    lspconfig = 'taplo',
  },
}

M.filetypes = vim.tbl_keys(M.config)

return M
