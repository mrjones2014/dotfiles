local is_work_project = require('my.utils.vcs').is_work_repo()

local suggestion_keymaps = {
  accept = '<C-CR>',
  accept_line = '<C-t>',
  next = '<C-n>',
  prev = '<C-p>',
  dismiss = '<C-d>',
}

local cody_providers = {
  ['avante-cody-claude-sonnet'] = {
    endpoint = 'https://1password.sourcegraphcloud.com',
    api_key_name = 'SRC_ACCESS_TOKEN',
    model = 'anthropic::2024-10-22::claude-sonnet-4-latest',
  },
  ['avante-cody-claude-opus'] = {
    model = 'anthropic::2024-10-22::claude-opus-4-thinking-latest',
    endpoint = 'https://1password.sourcegraphcloud.com',
    api_key_name = 'SRC_ACCESS_TOKEN',
  },
}

local providers = vim.tbl_deep_extend('force', {
  copilot = { model = 'gpt-5' },
}, is_work_project and cody_providers or {})

return {
  'yetone/avante.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'MunifTanjim/nui.nvim',
    {
      'brewinski/avante-cody.nvim',
      enabled = is_work_project,
      config = function()
        local token, err = require('op').get_secret(
          'op://dvqle3hea253riyk5gatbxf3o4/dd46jdd5tvwm5uk375lm3pujwm/credential',
          'S2EWWY7HCZDGFOQ7WOPBGAC2LY'
        )
        if not token then
          local msg = 'Failed to get SRC_ACCESS_TOKEN: ' .. (err or 'unknown error')
          vim.notify(msg, vim.log.levels.ERROR)
          error(msg)
        end
        vim.env.SRC_ACCESS_TOKEN = token
        require('avante-cody').setup({
          models = cody_providers,
        })
      end,
    },
    { 'folke/snacks.nvim' },
    {
      'zbirenbaum/copilot.lua',
      enabled = not is_work_project,
      -- Trick to load Copilot for relevant filetypes
      event = 'LspAttach',
      cmd = 'Copilot',
      dependencies = {
        {
          'fang2hou/blink-copilot',
          dependencies = {
            'saghen/blink.cmp',
            opts = function(_, opts)
              require('my.utils.completion').register_filetype_source(opts, nil, { 'copilot' }, {
                copilot = {
                  name = 'Copilot',
                  module = 'blink-copilot',
                  -- push copilot suggestions lower than LSP suggestions
                  score_offset = -20,
                  async = true,
                },
              })
            end,
          },
        },
      },
      opts = {
        copilot_model = 'gpt-5',
        suggestion = {
          auto_trigger = true,
          keymap = suggestion_keymaps,
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
    {
      'Kaiser-Yang/blink-cmp-avante',
      dependencies = {
        {
          'saghen/blink.cmp',
          opts = function(_, opts)
            require('my.utils.completion').register_filetype_source(opts, 'AvanteInput', { 'avante' }, {
              avante = {
                name = 'Avante',
                module = 'blink-cmp-avante',
                -- show Avante commands first
                score_offset = 100,
                async = true,
              },
            })
          end,
        },
      },
    },
  },
  build = 'make',
  version = false,
  cmd = {
    'AvanteAsk',
    'AvanteBuild',
    'AvanteChat',
    'AvanteChatNew',
    'AvanteClear',
    'AvanteToggle',
  },
  keys = {
    { '<leader>aa', vim.cmd.AvanteAsk, desc = 'avante: ask', mode = { 'n', 'v' } },
    { '<leader>ae', desc = 'avante: edit', mode = { 'v' } },
    { '<leader>aB', desc = 'avante: add all open buffers' },
    { '<leader>ac', desc = 'avante: add current buffer' },
    { '<leader>aC', desc = 'avante: toggle selection' },
    { '<leader>af', vim.cmd.AvanteFocus, desc = 'avante: focus' },
    { '<leader>ah', desc = 'avante: select history' },
    { '<leader>an', desc = 'avante: new ask' },
    { '<leader>at', vim.cmd.AvanteToggle, desc = 'Avante: toggle' },
  },
  ---@module 'avante'
  ---@type avante.Config
  opts = {
    -- default provider
    provider = is_work_project and 'avante-cody-claude-sonnet' or 'copilot',
    providers = providers,
    behavior = {
      -- using copilot for this
      auto_suggestions = false,
    },
    mappings = {
      suggestion = is_work_project and suggestion_keymaps or nil,
    },
    input = { provider = 'snacks' },
    -- Recommended settings to avoid rate limits
    mode = 'legacy',
    disabled_tools = {
      'insert',
      'create',
      'str_replace',
      'replace_in_file',
    },
  },
  prompt_logger = {
    enabled = false,
  },
}
