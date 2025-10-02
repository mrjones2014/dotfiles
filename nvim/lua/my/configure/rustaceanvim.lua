return {
  'mrcjkb/rustaceanvim',
  ft = 'rust',
  version = '^5',
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
  dependencies = { 'mrjones2014/codesettings.nvim' },
  init = function()
    vim.g.rustaceanvim = {
      server = {
        cmd = { vim.env.NVIM_RUST_ANALYZER },
        -- I want VS Code settings to override my settings,
        -- not the other way around, so use codesettings.nvim
        -- instead of rustaceanvim's built-in vscode settings loader
        load_vscode_settings = false,
        -- the global hook doesn't work when configuring rust-analyzer with rustaceanvim
        settings = function(_, config)
          return require('codesettings').with_vscode_settings('rust-analyzer', config)
        end,
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
              excludeDirs = {
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
