return {
  'LionC/nest.nvim',
  config = function()
    local nest = require('nest')
    local keymaps = require('modules.keymaps')
    nest.applyKeymaps(keymaps.default)
  end,
}
