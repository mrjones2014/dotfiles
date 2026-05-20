return {
  {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    -- see also queries/jjdescription/injections.scm
    ft = { 'markdown', 'jjdescription' },
    opts = { completions = { lsp = { enabled = true } } },
  },
  {
    'OXY2DEV/helpview.nvim',
    ft = 'help',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
  },
}
