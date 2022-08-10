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
  after = 'onedarkpro.nvim',
  config = function()
    local colors = require('onedarkpro').get_colors('onedark_vibrant')
    local utils = require('onedarkpro.utils')
    -- for some reason Lua LSP thinks this returns a table and not a string
    -- so tostring() it to get rid of warnings
    local gray = tostring(utils.lighten('#000000', 0.1, '#272727'))
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
          guibg = colors.bg,
          gui = 'italic',
        },
        fill = {
          guifg = gray,
          guibg = gray,
        },
        separator = {
          guifg = gray,
          guibg = '#000000',
        },
        separator_visible = {
          guifg = gray,
          guibg = '#000000',
        },
        separator_selected = {
          guifg = gray,
          guibg = '#000000',
        },
      },
    })
  end,
}
