return {
  {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter', branch = 'main' },
    ft = { 'markdown', 'codecompanion', 'codesettings-output', 'opencode', 'opencode_output' },
  },
  {
    'OXY2DEV/helpview.nvim',
    ft = 'help',
    dependencies = { 'nvim-treesitter/nvim-treesitter', branch = 'main' },
  },
}
