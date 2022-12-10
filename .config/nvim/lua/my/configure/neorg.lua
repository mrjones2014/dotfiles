return {
  'nvim-neorg/neorg',
  after = 'nvim-treesitter',
  -- ft = 'norg',
  -- cmd = 'Neorg',
  -- module = 'neorg',
  config = function()
    require('neorg').setup({
      load = {
        ['core.defaults'] = {},
        ['core.export'] = {
          config = {
            export_dir = string.format('%s/docs/md/', vim.env.HOME),
          },
        },
        ['core.export.markdown'] = {
          config = {
            extensions = { 'todo-items-basic', 'todo-items-pending', 'todo-items-extended', 'definition-lists' },
          },
        },
        ['core.norg.dirman'] = {
          config = {
            workspaces = {
              default = '~/docs/norg/',
            },
            default_workspace = 'default',
          },
        },
        ['core.keybinds'] = {
          config = {
            neorg_leader = '<BS>',
          },
        },
        ['core.norg.concealer'] = {},
      },
    })
  end,
}
