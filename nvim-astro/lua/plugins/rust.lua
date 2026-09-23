-- `pack.rust` hardcodes a codelldb DAP adapter by probing mason-registry. With Mason
-- disabled that probe fails and it falls back to `get_codelldb_adapter()` with no
-- arguments, which resolves `command` to nil and fails validation:
--
--   rustaceanvim: Invalid config: rustaceanvim.dap.adapter.executable.command
--   [server]: expected string, got nil
--
-- rustaceanvim's *own* default already falls through to lldb-dap, which nix provides
-- via the `lldb` package, so that's what's restored here.
--
-- The pack's `config` does `extend_tbl(opts, vim.g.rustaceanvim)`, i.e. anything set
-- on `vim.g.rustaceanvim` beats the pack. That's why this is an `init`.
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
