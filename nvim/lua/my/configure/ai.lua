local window = require('my.utils.window')
local hosts = require('my.utils.hosts')

return {
  'olimorris/codecompanion.nvim',
  dev = true,
  enabled = not hosts.is_server(),
  dependencies = {
    'folke/snacks.nvim',
    'nvim-lua/plenary.nvim',
    { 'mrjones2014/codecompanion-ui.nvim', dev = true },
    { 'MeanderingProgrammer/render-markdown.nvim', ft = { 'codecompanion', 'codecompanion_input' } },
  },
  version = false,
  cmd = {
    'CodeCompanionChat',
    'CodeCompanionClear',
    'CodeCompanionActions',
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
    {
      '<leader>af',
      function()
        if require('codecompanion-ui').is_visible() then
          require('codecompanion-ui').focus_input()
        else
          -- Fallback: find any CC window
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            local buf = vim.api.nvim_win_get_buf(win)
            if vim.bo[buf].filetype == 'codecompanion' and not window.is_floating_window(win) then
              vim.api.nvim_set_current_win(win)
              break
            end
          end
        end
      end,
      desc = 'codecompanion: focus',
    },
    {
      '<leader>at',
      function()
        require('codecompanion').toggle()
      end,
      desc = 'CodeCompanion: toggle',
    },
  },
  opts = {
    prompt_library = {
      markdown = {
        dirs = { '~/git/dotfiles/prompts' },
      },
    },
    adapters = {
      acp = {
        claude_code = function()
          local ok, op = pcall(require, 'op')
          if not ok then
            error('op.nvim is not installed, claude_code adapter will not work', vim.log.levels.ERROR)
          end
          local token = hosts.is_work_computer()
              and assert(
                op.get_secret('op://Employee/1Password Claude Token/password', 'AKHM3DPGNZFUJOY7N4UAWAMLIE'),
                'Failed to retrieve 1Password Claude Token'
              )
            or assert(
              op.get_secret('op://Private/Claude/token', '3UBYV6PWJZAS7HTEKHDSQ7HPUA'),
              'Failed to retrieve personal Claude token'
            )
          return require('codecompanion.adapters').extend('claude_code', {
            defaults = { mode = 'plan', model = 'opus' },
            env = {
              CLAUDE_CODE_OAUTH_TOKEN = token,
            },
          })
        end,
      },
    },
    extensions = {
      ui = { enabled = true },
    },
    interactions = {
      inline = { adapter = nil },
      cmd = { adapter = 'claude_code' },
      chat = {
        adapter = 'claude_code',
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
