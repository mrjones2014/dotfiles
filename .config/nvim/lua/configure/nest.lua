return {
  'LionC/nest.nvim',
  config = function()
    local nest = require('nest')
    local keymaps = require('keymap')
    nest.applyKeymaps(keymaps.default)
  end,
}
