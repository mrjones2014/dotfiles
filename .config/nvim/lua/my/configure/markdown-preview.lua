return {
  'iamcco/markdown-preview.nvim',
  ft = { 'markdown', 'md' },
  init = function()
    vim.g.mkdp_theme = 'dark'
  end,
  build = function()
    vim.fn['mkdp#util#install']()
  end,
}
