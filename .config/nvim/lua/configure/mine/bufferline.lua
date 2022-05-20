local path

local paths = require('paths')
if vim.fn.isdirectory(paths.join(paths.home, 'git/personal/bufferline.nvim')) > 0 then
  path = '~/git/personal/bufferline.nvim'
else
  path = 'mrjones2014/bufferline.nvim'
end

return {
  path,
  requires = { 'famiu/bufdelete.nvim' },
  after = 'lighthaus.nvim',
  config = function()
    local colors = require('lighthaus.colors')
    require('bufferline').setup({
      options = {
        mode = 'window',
        max_name_length = 24,
        close_command = 'Bdelete %d',
        separator_style = 'slant',
        themable = true,
      },
      highlights = {
        buffer_selected = {
          guifg = colors.fg,
          guibg = colors.bg_dark,
          gui = 'italic',
        },
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
