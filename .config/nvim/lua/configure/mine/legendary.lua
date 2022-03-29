local path

local paths = require('paths')
if vim.fn.isdirectory(paths.join(paths.home, 'git/personal/legendary.nvim')) > 0 then
  path = '~/git/personal/legendary.nvim'
else
  path = 'mrjones2014/legendary.nvim'
end

return {
  path,
  -- bufdelete used in keymaps
  requires = { 'famiu/bufdelete.nvim' },
  config = function()
    require('legendary').setup({
      keymaps = require('keymap').default_keymaps(),
      commands = require('commands').default_commands(),
      autocmds = require('autocmds').default_autocmds(),
      select_prompt = function(kind)
        if kind == 'legendary.items' then
          return ' Legendary '
        end

        -- Convert kind to Title Case (e.g. legendary.keymaps => Legendary Keymaps)
        return ' ' .. string.gsub(' ' .. kind:gsub('%.', ' '), '%W%l', string.upper):sub(2) .. ' '
      end,
    })
  end,
}
