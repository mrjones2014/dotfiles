return {
  cmd = { 'graphql-lsp', 'server', '-m', 'stream' },
  filetypes = { 'graphql', 'gql', 'javascriptreact', 'typescriptreact' },
  root_dir = function(bufnr, on_dir)
    local fname = vim.api.nvim_buf_get_name(bufnr)
    on_dir(vim.fs.root(fname, { '.graphqlrc*', '.graphql.config.*', 'graphql.config.*' }))
  end,
}
