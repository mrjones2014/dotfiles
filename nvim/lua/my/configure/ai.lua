return {
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
  {
    'folke/sidekick.nvim',
    keys = {
      {
        '<leader>aa',
        function()
          require('sidekick.cli').toggle({ name = 'claude' })
        end,
        desc = 'sidekick: toggle',
        mode = 'n',
      },
      {
        '<leader>aa',
        function()
          require('sidekick.cli').send({ name = 'claude', msg = '{selection}' })
        end,
        desc = 'sidekick: send selection',
        mode = 'v',
      },
      {
        '<leader>af',
        function()
          require('sidekick.cli').focus()
        end,
        desc = 'sidekick: focus',
      },
    },
    opts = {
      cli = {
        mux = {
          backend = 'zellij',
          enabled = true,
        },
      },
    },
  },
  -- { 'MeanderingProgrammer/render-markdown.nvim', ft = { 'opencode', 'opencode_output' } },
  -- {
  --   'sudo-tee/opencode.nvim',
  --   keys = { '<leader>o' },
  --   dependencies = {
  --     'nvim-lua/plenary.nvim',
  --     'folke/snacks.nvim',
  --   },
  --   opts = {
  --     default_mode = 'plan',
  --     ui = {
  --       input = { text = { wrap = true } },
  --     },
  --     keymap = {
  --       input_window = {
  --         -- only submit with enter in normal mode, not insert mode
  --         ['<cr>'] = { 'submit_input_prompt', mode = { 'n' } },
  --         ['<s-cr>'] = false,
  --         -- don't close the window on `<esc>`,
  --         -- too easily to close accidentally when trying to exit insert mode
  --         ['<esc>'] = false,
  --       },
  --       output_window = {
  --         -- don't close the window on `<esc>`,
  --         -- too easily to close accidentally when trying to exit insert mode
  --         ['<esc>'] = false,
  --       },
  --       session_picker = {
  --         -- don't override <C-n>, that should be reserved for "next entry",
  --         -- i.e. <C-n> and <C-p>
  --         new_session = false,
  --       },
  --     },
  --   },
  -- },
}
