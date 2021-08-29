return {
  'f-person/git-blame.nvim',
  setup = function()
    vim.g.gitblame_date_format = '%m/%d/%y %I:%M %p'
  end,
}
