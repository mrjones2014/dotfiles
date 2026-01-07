return {
  {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter', branch = 'main' },
    opts = { file_types = { 'markdown', 'codecompanion', 'codesettings-output' } },
    ft = { 'markdown', 'codecompanion', 'codesettings-output' },
  },
  {
    'OXY2DEV/helpview.nvim',
    ft = 'help',
    dependencies = { 'nvim-treesitter/nvim-treesitter', branch = 'main' },
  },
}
