local path

if vim.fn.isdirectory(os.getenv('HOME') .. '/git/personal/legendary.nvim') > 0 then
  path = '~/git/personal/legendary.nvim'
else
  path = 'mrjones2014/legendary.nvim'
end

return {
  path,
  -- requires = '~/git/personal/which-key.nvim',
  config = function()
    require('legendary').setup({
      keymaps = require('keymap').default_keymaps,
      commands = require('keymap').default_commands,
      select_prompt = ' Legendary ',
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
    --     f = { '<cmd>Telescope find_files<cr>', 'Find File' },
    --   },
    -- }, {
    --   prefix = '<leader>',
    -- })
  end,
}
