return {
  localplugin('mrjones2014/legendary.nvim'),
  requires = {
    -- used by key mappings
    'fedepujol/move.nvim',
    -- used sometimes for testing integration
    -- 'folke/which-key.nvim',
  },
  config = function()
    require('legendary').setup({
      keymaps = require('my.legendary.keymap').default_keymaps(),
      commands = require('my.legendary.commands').default_commands(),
      autocmds = require('my.legendary.autocmds').default_autocmds(),
      functions = require('my.legendary.functions').default_functions(),
      col_separator_char = ' ',
      -- which_key = { auto_register = true },
    })

    -- require('which-key').setup({
    --   plugins = {
    --     presets = {
    --       operators = false,
    --       motions = false,
    --       text_objects = false,
    --       windows = false,
    --       nav = false,
    --       z = false,
    --       g = false,
    --     },
    --   },
    -- })
    -- require('which-key').register({
    --   f = {
    --     name = 'file', -- optional group name
    --     q = { '<cmd>Telescope find_files<cr>', 'Find File' },
    --   },
    -- }, {
    --   prefix = '<leader>',
    -- })
  end,
}
