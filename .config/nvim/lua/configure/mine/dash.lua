if vim.fn.isdirectory(os.getenv('HOME') .. '/git/personal/dash.nvim') > 0 then
  return {
    '~/git/personal/dash.nvim',
    -- requires = {
    --   'ibhagwan/fzf-lua',
    --   'vijaymarupudi/nvim-fzf',
    --   'camspiers/snap'
    -- }
  }
else
  return { 'mrjones2014/dash.nvim' }
end
