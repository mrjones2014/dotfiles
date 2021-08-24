return {
  'Pocco81/Catppuccino.nvim',
  config = function()
    local catppuccino = require('catppuccino')
    catppuccino.setup({
      integrations = {
        native_lsp = {
          enabled = true,
        },
        nvimtree = true,
        telescope = true,
        dashboard = true,
        bufferline = true,
        lsp_trouble = true,
        lsp_saga = true,
        indent_blankline = true,
      },
    })
    catppuccino.load()
  end,
}
