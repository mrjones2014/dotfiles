---@type LazySpec
return {
  { import = 'astrocommunity.pack.rust' },
  {
    'mrcjkb/rustaceanvim',
    init = function()
      vim.g.rustaceanvim = {
        dap = {
          adapter = {
            type = 'executable',
            command = vim.fn.exepath('lldb-dap'),
            name = 'lldb',
          },
        },
        server = {
          -- pinned to the nix rust-analyzer via extraWrapperArgs in nvim.nix
          cmd = { vim.env.NVIM_RUST_ANALYZER },
          on_attach = function()
            -- this semantic token has way too many false positives around macros
            vim.api.nvim_set_hl(0, '@lsp.type.unresolvedReference.rust', {})
          end,
          ---@type lsp.rust_analyzer
          default_settings = {
            ['rust-analyzer'] = {
              cargo = { targetDir = true },
              check = { allTargets = true, command = 'clippy' },
              diagnostics = { disabled = { 'inactive-code', 'unresolved-proc-macro' } },
              procMacro = { enable = true },
              imports = { group = { enable = false } },
              files = {
                excludeDirs = { 'target', 'node_modules', '.direnv', '.git' },
              },
            },
          },
        },
      }
    end,
  },
  {
    'AstroNvim/astrocore',
    ---@type AstroCoreOpts
    opts = {
      mappings = {
        n = {
          ['<Leader>rd'] = {
            function()
              vim.cmd.RustLsp('relatedDiagnostics')
            end,
            desc = 'Rust: related diagnostics',
          },
          ['<Leader>rc'] = {
            function()
              vim.cmd.vsp()
              vim.cmd.RustLsp('openCargo')
            end,
            desc = 'Rust: open Cargo.toml in vsplit',
          },
        },
      },
    },
  },
}
