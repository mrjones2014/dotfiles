return {
  'mistweaverco/kulala.nvim',
  keys = {
    { '<leader>ks', desc = 'Send request' },
    {
      '<leader>kg',
      function()
        require('kulala').scratchpad()
      end,
      desc = 'Open GQL Scratchpad',
    },
  },
  opts = {
    global_keymaps = true,
    global_keymaps_prefix = '<leader>k',
    ui = {
      win_opts = { wo = { foldenable = false } }, -- disable folds in response
      scratchpad_default_contents = {
        'GRAPHQL http://localhost:3791',
        'Accept: application/json',
        '',
        '',
      },
    },
  },
}
