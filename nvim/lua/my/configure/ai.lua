local window = require('my.utils.window')

local copilot = {
  name = 'copilot',
  model = 'gpt-5-codex',
}

return {
  'olimorris/codecompanion.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'franco-ruggeri/codecompanion-spinner.nvim',
    { 'folke/snacks.nvim' },
    {
      'zbirenbaum/copilot.lua',
      event = 'LspAttach',
      cmd = 'Copilot',
      config = {
        copilot_model = 'gpt-5-codex',
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
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          local buf = vim.api.nvim_win_get_buf(win)
          if vim.bo[buf].filetype == 'codecompanion' and not window.is_floating_window(win) then
            vim.api.nvim_set_current_win(win)
          end
        end
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
    extensions = { spinner = {} },
    strategies = {
      chat = {
        keymaps = {
          -- change this mapping because I use gx to open URLs
          clear = {
            modes = { n = 'gX' },
          },
        },
        adapter = copilot,
      },
      inline = {
        adapter = copilot,
      },
      cmd = {
        adapter = copilot,
      },
    },
  },
}
