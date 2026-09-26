---@type LazySpec
return {
  { import = 'astrocommunity.lsp.nvim-lint' },
  {
    -- need to fix selene root dir detection
    -- when editing in a subdirectory, such as
    -- working on `dotfiles/nvim` but `pwd` is
    -- `dotfiles`
    'mfussenegger/nvim-lint',
    opts = {
      linters = {
        selene = {
          args = {
            '--display-style',
            'json',
            '--config',
            function()
              local root = vim.fs.root(0, { 'selene.toml', 'selene.yml' })
              if not root then
                -- selene's own default; resolved against its cwd
                return 'selene.toml'
              end
              local toml = vim.fs.joinpath(root, 'selene.toml')
              return vim.uv.fs_stat(toml) and toml or vim.fs.joinpath(root, 'selene.yml')
            end,
            '-',
          },
        },
      },
    },
  },
}
