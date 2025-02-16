return {
  'mrcjkb/rustaceanvim',
  ft = 'rust',
  version = '^5',
  depenencies = { 'folke/neoconf.nvim' },
  init = function()
    local neoconf = require('neoconf')
    require('my.lsp.snippets').rust()
    vim.g.rustaceanvim = {
      server = {
        default_settings = {
          ['rust-analyzer'] = {
            cargo = { allFeatures = true, targetDir = true },
            check = {
              allTargets = true,
              command = 'clippy',
            },
            diagnostics = {
              disabled = { 'inactive-code', 'unresolved-proc-macro' },
            },
            procMacro = { enable = true },
            flags = { exit_timeout = 100 },
            files = {
              -- Make rustaceanvim effectively work with neoconf for the fields we care about
              excludeDirs = vim.tbl_get(neoconf.get('vscode') or {}, 'rust-analyzer', 'files', 'excludeDirs') or {
                'target',
                'node_modules',
                '.direnv',
                '.git',
              },
            },
          },
        },
      },
    }
  end,
}
