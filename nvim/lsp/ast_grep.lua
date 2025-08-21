return {
  cmd = { 'ast-grep', 'lsp' },
  filetypes = {
    'c',
    'cpp',
    'rust',
    'go',
    'java',
    'python',
    'javascript',
    'javascriptreact',
    'javascript.jsx',
    'typescript',
    'typescriptreact',
    'typescript.tsx',
    'html',
    'css',
    'kotlin',
    'dart',
    'lua',
  },
  root_markers = { 'sgconfig.yaml', 'sgconfig.yml' },
  workspace_required = true,
  reuse_client = function(client, config)
    config.cmd_cwd = config.root_dir
    return client.config.cmd_cwd == config.cmd_cwd
  end,
}
