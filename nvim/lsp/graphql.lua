return {
  cmd = { 'graphql-lsp', 'server', '-m', 'stream' },
  filetypes = { 'graphql', 'javascriptreact', 'typescriptreact' },
  root_dir = function(bufnr, on_dir)
    local fname = vim.api.nvim_buf_get_name(bufnr)
    on_dir(vim.fs.root(fname, { '.graphqlrc', '.graphqlrc.yml', '.graphqlrc.yaml', '.graphql.config.json' }))
  end,
}
