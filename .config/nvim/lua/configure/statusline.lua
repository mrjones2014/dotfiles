return {
  'windwp/windline.nvim',
  config = function()
    local components = require('configure.statusline.components')
    local sections = {
      { components.mode, { 'black', 'ActiveBg' } },
      { '', { 'ActiveBg', 'blue_dark' } },
      { components.branchName, { 'ActiveBg', 'blue_dark' } },
      { '', { 'blue_dark', 'black' } },
      { components.filetypeIcon, { 'ActiveBg', 'black' } },
      { components.filename, { 'ActiveBg', 'black' } },
      { '%=', { 'ActiveBg', 'black' } },
      { components.filetypeIcon, { 'ActiveBg', 'black' } },
      { components.filetype, { 'white', 'black' } },
      { '', { 'blue_dark', 'black' } },
      { components.progress, { 'ActiveBg', 'blue_dark' } },
      { '', { 'ActiveBg', 'blue_dark' } },
      { components.lineCol, { 'black', 'ActiveBg' } },
    }

    local defaultStatusLine = {
      filetypes = { 'default' },
      active = sections,
      inactive = sections,
    }

    require('windline').setup({
      colors_name = function(colors)
        colors.blue_dark = '#132234'
      end,
      statuslines = {
        defaultStatusLine,
      },
    })

    vim.cmd('autocmd VimEnter * :WindLineFloatToggle')
  end,
}
