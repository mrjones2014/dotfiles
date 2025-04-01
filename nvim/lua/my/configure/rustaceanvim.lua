return {
  'mrcjkb/rustaceanvim',
  ft = 'rust',
  version = '^5',
  depenencies = { 'folke/neoconf.nvim' },
  keys = {
    {
      '<leader>rd',
      function()
        vim.cmd.RustLsp('relatedDiagnostics')
      end,
      desc = 'Open related diagnostics',
    },
    {
      '<leader>oc',
      function()
        vim.cmd.vsp()
        vim.cmd.RustLsp('openCargo')
      end,
      desc = 'Open Cargo.toml in vert split',
    },
  },
  init = function()
    local neoconf = require('neoconf')
    require('my.lsp.snippets').rust()
    vim.g.rustaceanvim = {
      server = {
        cmd = { vim.env.NVIM_RUST_ANALYZER },
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
