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
  opts = {
    adapters = {
      chat = 'ollama',
      inline = 'ollama',
    },
  },
}
