return {
  'f-person/git-blame.nvim',
  event = 'BufLeave', -- when leaving dashboard buffer
  setup = function()
    vim.g.gitblame_date_format = '%m/%d/%y %I:%M %p'
  end,
}
