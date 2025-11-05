return {
  'olimorris/codecompanion.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
    { 'folke/snacks.nvim' },
    {
      'zbirenbaum/copilot.lua',
      event = 'LspAttach',
      cmd = 'Copilot',
      opts = {
        copilot_model = 'GPT-5-Codex',
        suggestion = {
          auto_trigger = true,
          keymap = {
            accept = '<C-CR>',
            accept_line = '<C-t>',
            next = '<C-n>',
            prev = '<C-p>',
            dismiss = '<C-d>',
          },
        },
        server_opts_overrides = {
          settings = {
            telemetry = {
              telemetryLevel = 'off',
            },
          },
        },
      },
    },
  },
  version = false,
  cmd = {
    'CodeCompanionChat',
    'CodeCompanionInline',
    'CodeCompanionRefactor',
    'CodeCompanionNew',
    'CodeCompanionClear',
    'CodeCompanionToggle',
  },
  keys = {
    {
      '<leader>aa',
      function()
        require('codecompanion').chat()
      end,
      desc = 'codecompanion: chat',
      mode = { 'n', 'v' },
    },
    { '<leader>ae', desc = 'codecompanion: edit', mode = { 'v' } },
    { '<leader>aB', desc = 'codecompanion: add all open buffers' },
    { '<leader>ac', desc = 'codecompanion: add current buffer' },
    { '<leader>aC', desc = 'codecompanion: toggle selection' },
    {
      '<leader>af',
      function()
        require('codecompanion').focus()
      end,
      desc = 'codecompanion: focus',
    },
    { '<leader>ah', desc = 'codecompanion: select history' },
    { '<leader>an', desc = 'codecompanion: new chat' },
    {
      '<leader>at',
      function()
        require('codecompanion').toggle()
      end,
      desc = 'CodeCompanion: toggle',
    },
  },
  opts = {
    strategies = {
      chat = {
        keymaps = {
          -- change this mapping because I use gx to open URLs
          clear = {
            modes = { n = 'gX' },
          },
        },
      },
    },
  },
}
