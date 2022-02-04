local path = ''

if vim.fn.isdirectory(os.getenv('HOME') .. '/git/personal/legendary.nvim') > 0 then
  path = '~/git/personal/legendary.nvim'
else
  path = 'mrjones2014/legendary.nvim'
end

return {
  path,
  config = function()
    require('legendary').setup({ keymaps = require('keymap').default_keymaps })
  end,
}
