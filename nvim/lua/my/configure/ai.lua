local window = require('my.utils.window')
local hosts = require('my.utils.hosts')

-- Custom chat UI

return {
  'olimorris/codecompanion.nvim',
  dev = true,
  dependencies = {
    'folke/snacks.nvim',
    'nvim-lua/plenary.nvim',
    -- TODO switch this back if/when the PR merges
    -- https://github.com/ravitemer/codecompanion-history.nvim/pull/74
    -- 'ravitemer/codecompanion-history.nvim',
    { 'cenk1cenk2/codecompanion-history.nvim', branch = 'patch-1' },
    { 'MeanderingProgrammer/render-markdown.nvim', ft = { 'codecompanion' } },
    {
      'zbirenbaum/copilot.lua',
      event = 'LspAttach',
      cmd = 'Copilot',
      config = {
        suggestion = {
          auto_trigger = true,
          keymap = {
            accept = '<C-CR>',
            accept_line = '<C-t>',
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
        if require('codecompanion-nui').is_visible() then
          require('codecompanion-nui').focus_input()
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
      history = {
        enabled = true,
        opts = {
          picker = 'snacks',
          expiration_days = 7,
          -- this setting doesn't play nicely with ACP adapters
          -- continue_last_chat = true,
          delete_on_clearing_chat = true,
          title_generation_opts = {
            adapter = 'copilot',
            model = 'gpt-4o',
            refresh_every_n_prompts = 2,
            max_refreshes = 3,
          },
          summary = {
            generation_opts = {
              adapter = 'copilot',
              model = 'gpt-4o',
            },
          },
        },
      },
      nui = { enabled = true },
    },
    interactions = {
      chat = {
        keymaps = {
          -- change this mapping because I use gx to open URLs
          clear = {
            modes = { n = 'gX' },
          },
        },
        adapter = 'claude_code',
      },
      inline = { adapter = 'copilot' },
      cmd = { adapter = 'claude_code' },
    },
  },
}
