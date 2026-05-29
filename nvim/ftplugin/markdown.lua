vim.api.nvim_set_option_value('wrap', true, { win = 0 })
vim.api.nvim_set_option_value('linebreak', true, { win = 0 })

-- set up autocmd to revert the above options when another filetype is focused
vim.api.nvim_create_autocmd('BufWinEnter', {
  callback = function()
    if vim.bo.ft == 'markdown' then
      vim.api.nvim_set_option_value('wrap', true, { win = 0 })
      vim.api.nvim_set_option_value('linebreak', true, { win = 0 })
    else
      vim.api.nvim_set_option_value('wrap', false, { win = 0 })
      vim.api.nvim_set_option_value('linebreak', false, { win = 0 })
    end
  end,
})
