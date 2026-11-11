---@type LazySpec
return {
  { import = 'astrocommunity.pack.rust' },
  {
    'mrcjkb/rustaceanvim',
    specs = {
      'AstroNvim/astrocore',
      ---@type AstroCoreOpts
      opts = {
        options = {
          g = {
            rustaceanvim = {
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
                  require('astrocore').set_mappings({
                    n = {
                      -- group title for which-key
                      ['<Leader>r'] = { desc = 'Rust LSP', buffer = 0 },
                      ['<Leader>rd'] = {
                        function()
                          vim.cmd.RustLsp('relatedDiagnostics')
                        end,
                        desc = 'Rust: related diagnostics',
                        buf = 0,
                      },
                      ['<Leader>rc'] = {
                        function()
                          vim.cmd.vsp()
                          vim.cmd.RustLsp('openCargo')
                        end,
                        desc = 'Rust: open Cargo.toml in vsplit',
                        buf = 0,
                      },
                    },
                  })
                end,
                ---@type lsp.rust_analyzer
                default_settings = {
                  ['rust-analyzer'] = {
                    cargo = { targetDir = true },
                    check = { allTargets = true, command = 'clippy' },
                    -- don't saturate every core while indexing huge workspaces
                    cachePriming = { numThreads = 'physical' },
                    diagnostics = { disabled = { 'inactive_code', 'unresolved_proc_macro' } },
                    procMacro = { enable = true },
                    imports = { group = { enable = false } },
                    files = {
                      -- rust-analyzer's own watcher honours `exclude`; Neovim's recursive
                      -- fs_event watcher would hand it every write under target/
                      watcher = 'server',
                      exclude = { 'target', 'node_modules', '.direnv', '.git', '.jj' },
                    },
                  },
                },
              },
            },
          },
        },
      },
    },
  },
}
