return {
  'Pocco81/Catppuccino.nvim',
  config = function()
    local catppuccino = require('catppuccino')
    catppuccino.setup({
      colorscheme = 'soft_manilo',
      integrations = {
        native_lsp = {
          enabled = true,
        },
        nvimtree = {
          enabled = true,
          show_root = true,
        },
        telescope = true,
        dashboard = true,
        bufferline = true,
        lsp_trouble = true,
        lsp_saga = true,
        indent_blankline = {
          enabled = true,
          colored_indent_levels = true,
        },
      },
    })
    catppuccino.load()
  end,
}
