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
    mason = 'typescript-language-server',
  },
  ['lua'] = {
    patterns = { '*.lua' },
    lspconfig = 'sumneko_lua',
    mason = 'lua-language-server',
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
}

M.filetypes = vim.tbl_keys(M.config)

return M
