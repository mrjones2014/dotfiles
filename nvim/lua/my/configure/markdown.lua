return {
  {
    'MeanderingProgrammer/markdown.nvim',
    main = 'render-markdown',
    dependencies = { 'nvim-treesitter/nvim-treesitter', branch = 'main' },
    opts = {},
    ft = 'markdown',
  },
  {
    'OXY2DEV/helpview.nvim',
    ft = 'help',
    dependencies = { 'nvim-treesitter/nvim-treesitter', branch = 'main' },
  },
}
