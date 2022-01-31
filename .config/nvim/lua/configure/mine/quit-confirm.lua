if vim.fn.isdirectory(os.getenv('HOME') .. '/git/personal/quit-confirm.nvim') > 0 then
  return {
    '~/git/personal/quit-confirm.nvim',
    config = function()
      require('quit-confirm').setup({
        only_in_dirs = { '~/git/work/core/' },
      })
    end,
  }
else
  return {
    'mrjones2014/quit-confirm.nvim',
    config = function()
      require('quit-confirm').setup({
        only_in_dirs = { '~/git/work/core/' },
      })
    end,
  }
end
