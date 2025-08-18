return {
  {
    'MeanderingProgrammer/markdown.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter', branch = 'main' },
    opts = { file_types = { 'markdown', 'Avante' } },
    ft = { 'markdown', 'Avante' },
  },
  {
    'OXY2DEV/helpview.nvim',
    ft = 'help',
    dependencies = { 'nvim-treesitter/nvim-treesitter', branch = 'main' },
  },
}
