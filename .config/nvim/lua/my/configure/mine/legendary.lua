return {
  localplugin('mrjones2014/legendary.nvim'),
  requires = {
    -- used by key mappings
    'fedepujol/move.nvim',
    -- used sometimes for testing integration
    'folke/which-key.nvim',
  },
  config = function()
    require('legendary').setup({
      keymaps = require('my.legendary.keymap').default_keymaps(),
      commands = require('my.legendary.commands').default_commands(),
      autocmds = require('my.legendary.autocmds').default_autocmds(),
      functions = require('my.legendary.functions').default_functions(),
      col_separator_char = '',
      auto_register_which_key = true,
      select_prompt = function(kind)
        if kind == 'legendary.items' then
          return ' Legendary '
        end

        -- Convert kind to Title Case (e.g. legendary.keymaps => Legendary Keymaps)
        return ' ' .. string.gsub(' ' .. kind:gsub('%.', ' '), '%W%l', string.upper):sub(2) .. ' '
      end,
    })

    require('which-key').setup({
      plugins = {
        presets = {
          operators = false,
          motions = false,
          text_objects = false,
          windows = false,
          nav = false,
          z = false,
          g = false,
        },
      },
    })
    require('which-key').register({
      f = {
        name = 'file', -- optional group name
        f = { '<cmd>Telescope find_files<cr>', 'Find File' },
      },
    }, {
      prefix = '<leader>',
    })
  end,
}
