return {
  'akinsho/nvim-bufferline.lua',
  requires = { 'famiu/bufdelete.nvim' },
  after = 'lighthaus.nvim',
  config = function()
    local colors = require('lighthaus.colors')
    require('bufferline').setup({
      options = {
        max_name_length = 24,
        close_command = 'Bdelete %d',
        separator_style = 'slant',
        themable = true,
      },
      highlights = {
        fill = {
          guifg = colors.blacker_than_black,
          guibg = colors.blacker_than_black,
        },
        separator = {
          guifg = colors.blacker_than_black,
          guibg = colors.bg_dark,
        },
        separator_visible = {
          guifg = colors.blacker_than_black,
          guibg = colors.bg_dark,
        },
        separator_selected = {
          guifg = colors.blacker_than_black,
          guibg = colors.bg_dark,
        },
      },
    })
  end,
}
