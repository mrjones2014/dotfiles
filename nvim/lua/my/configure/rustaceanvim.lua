return {
  'mrcjkb/rustaceanvim',
  ft = 'rust',
  version = '^7',
  dependencies = { 'mrjones2014/codesettings.nvim' },
  init = function()
    vim.g.rustaceanvim = {
      server = {
        cmd = { vim.env.NVIM_RUST_ANALYZER },
        -- I want VS Code settings to override my settings,
        -- not the other way around, so rely on codesettings.nvim
        -- instead of rustaceanvim's built-in vscode settings loader
        load_vscode_settings = false,
        on_attach = function()
          require('which-key').add({
            {
              '<leader>rd',
              function()
                vim.cmd.RustLsp('relatedDiagnostics')
              end,
              desc = 'Open related diagnostics',
            },
            {
              '<leader>rc',
              function()
                vim.cmd.vsp()
                vim.cmd.RustLsp('openCargo')
              end,
              desc = 'Open Cargo.toml in vert split',
            },
          })
        end,
        ---@type lsp.rust_analyzer
        default_settings = {
          ['rust-analyzer'] = {
            cargo = { targetDir = true },
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
