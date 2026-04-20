return {
  'mrcjkb/rustaceanvim',
  ft = 'rust',
  version = '^8',
  init = function()
    vim.g.rustaceanvim = {
      server = {
        cmd = { vim.env.NVIM_RUST_ANALYZER },
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
            check = { allTargets = true, command = 'clippy' },
            diagnostics = { disabled = { 'inactive-code', 'unresolved-proc-macro' } },
            procMacro = { enable = true },
            imports = { group = { enable = false } },
            lens = {
              implementations = { enable = true },
              references = {
                enable = true,
                adt = { enable = true },
                enumVariant = { enable = true },
                trait = { enable = true },
              },
            },
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
