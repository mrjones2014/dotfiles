return {
  cmd = { 'graphql-lsp', 'server', '-m', 'stream' },
  filetypes = { 'graphql', 'javascriptreact', 'typescriptreact' },
  root_markers = { '.graphqlrc*', '.graphql.config.*', 'graphql.config.*' },
}
