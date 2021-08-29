return {
  'tpope/vim-sleuth',
  event = 'BufLeave', -- when leaving dashboard buffer
  setup = function()
    -- automatically sleuth indent styles
    vim.g.sleuth_automatic = 1
  end,
}
