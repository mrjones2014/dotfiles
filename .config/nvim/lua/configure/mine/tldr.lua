local path

if vim.fn.isdirectory(os.getenv('HOME') .. '/git/personal/tldr.nvim') > 0 then
  path = '~/git/personal/tldr.nvim'
else
  path = 'mrjones2014/tldr.nvim'
end

return {
  path,
  config = function()
    require('tldr').setup({ tldr_args = '--color always' })
  end,
}
