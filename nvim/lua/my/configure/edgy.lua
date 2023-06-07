return {
  'folke/edgy.nvim',
  dependencies = {
    {
      'nvim-neo-tree/neo-tree.nvim',
      config = function()
        require('neo-tree').setup({
          open_files_do_not_replace_types = { 'terminal', 'Trouble', 'qf', 'edgy' },
        })
      end,
    },
    {
      'simrat39/symbols-outline.nvim',
      config = function()
        require('symbols-outline').setup()
      end,
    },
  },
  event = 'VeryLazy',
  config = function()
    require('edgy').setup({
      exit_when_last = true,
      animate = {
        enabled = false,
      },
      options = {
        right = { size = 30 },
      },
      keys = {
        ['q'] = function(win)
          win.view.edgebar:close()
        end,
      },
      right = {
        {
          title = 'Neo-Tree Buffers',
          ft = 'neo-tree',
          filter = function(buf)
            return vim.b[buf].neo_tree_source == 'buffers'
          end,
          pinned = true,
          open = 'Neotree position=top buffers',
          size = { height = 0.1 },
        },
        {
          title = 'Neo-Tree',
          ft = 'neo-tree',
          pinned = true,
          filter = function(buf)
            return vim.b[buf].neo_tree_source == 'filesystem'
          end,
          size = { height = 0.5 },
        },
        {
          ft = 'Outline',
          pinned = true,
          open = 'SymbolsOutline',
        },
      },
    })
  end,
}
