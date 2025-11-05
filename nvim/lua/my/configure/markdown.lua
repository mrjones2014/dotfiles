return {
  {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter', branch = 'main' },
    opts = { file_types = { 'markdown', 'codecompanion' } },
    ft = { 'markdown', 'codecompanion' },
  },
  {
    'OXY2DEV/helpview.nvim',
    ft = 'help',
    dependencies = { 'nvim-treesitter/nvim-treesitter', branch = 'main' },
  },
}
