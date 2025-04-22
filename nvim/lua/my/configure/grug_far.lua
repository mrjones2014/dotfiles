return {
  'MagicDuck/grug-far.nvim',
  cmd = { 'GrugFar', 'GrugFarWithin' },
  keys = {
    {
      '<leader><leader>s',
      function()
        require('grug-far').open({})
      end,
      mode = 'n',
      desc = 'Search and replace',
    },
    {
      '<leader><leader>f',
      function()
        require('grug-far').open({ prefills = { paths = vim.fn.expand('%') } })
      end,
      desc = 'Search and replace in current file',
    },
    {
      '<leader><leader>s',
      function()
        require('grug-far').open({ visualSelectionUsage = 'operate-within-range' })
      end,
      mode = 'v',
      desc = 'Search and replace visual selection',
    },
  },
}
