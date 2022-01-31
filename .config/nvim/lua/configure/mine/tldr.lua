if vim.fn.isdirectory(os.getenv('HOME') .. '/git/personal/tldr.nvim') > 0 then
  return {
    '~/git/personal/tldr.nvim',
    config = function()
      require('tldr').setup({ tldr_args = '--color always' })
    end,
  }
else
  return {
    'mrjones2014/tldr.nvim',
    config = function()
      require('tldr').setup({ tldr_args = '--color always' })
    end,
  }
end
