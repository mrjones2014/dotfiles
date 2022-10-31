return {
  'iamcco/markdown-preview.nvim',
  ft = { 'markdown', 'md' },
  setup = function()
    vim.g.mkdp_theme = 'dark'
  end,
  run = function()
    vim.fn['mkdp#util#install']()
  end,
}
