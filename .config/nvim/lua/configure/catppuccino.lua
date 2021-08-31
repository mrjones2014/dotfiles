return {
  'Pocco81/Catppuccino.nvim',
  config = function()
    local catppuccino = require('catppuccino')
    catppuccino.setup({
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
        indent_blankline = true,
      },
    }, {
      bg = '#212222',
      bg_sidebar = '#2a2b2b',
    })
    catppuccino.load()
  end,
}
