local path = ''

if vim.fn.isdirectory(os.getenv('HOME') .. '/git/personal/dash.nvim') > 0 then
  path = '~/git/personal/dash.nvim'
else
  path = 'mrjones2014/dash.nvim'
end

return {
  path,
  -- requires = {
  --   'ibhagwan/fzf-lua',
  --   'vijaymarupudi/nvim-fzf',
  --   'camspiers/snap'
  -- }
}
