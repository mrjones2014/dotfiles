---@type LazySpec
return {
  { import = 'astrocommunity.markdown-and-latex.render-markdown-nvim' },
  {
    'MeanderingProgrammer/render-markdown.nvim',
    opts = {
      file_types = {
        'markdown',
        'codecompanion',
        'codecompanion_input',
        'jjdescription',
        'codesettings-output',
      },
      completions = { lsp = { enabled = true } },
    },
  },
}
