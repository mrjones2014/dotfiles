return {
  'olimorris/codecompanion.nvim',
  dev = true,
  dependencies = {
    'nvim-treesitter/nvim-treesitter',
    'nvim-lua/plenary.nvim',
    {
      'stevearc/dressing.nvim', -- Optional: Improves the default Neovim UI
      opts = {},
    },
  },
  cmd = {
    'CodeCompanion',
    'CodeCompanionChat',
    'CodeCompanionToggle',
    'CodeCompanionActions',
  },
  keys = { {
    '<leader>cc',
    function()
      require('codecompanion').actions()
    end,
    desc = 'CodeCompanion Actions',
  } },
  opts = {
    adapters = {
      chat = 'ollama',
      inline = 'ollama',
    },
  },
}
