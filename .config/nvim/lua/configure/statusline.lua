return {
  'windwp/windline.nvim',
  config = function()
    local components = require('configure.statusline.components')
    local sections = {
      { components.mode, { 'black', 'ActiveBg' } },
      { '', { 'ActiveBg', 'InactiveFg' } },
      { components.branchName, { 'ActiveBg', 'InactiveFg' } },
      { '', { 'InactiveFg', 'black' } },
      { components.filetypeIcon, { 'ActiveBg', 'black' } },
      { components.filename, { 'ActiveBg', 'black' } },
      { '%=', '' },
      { components.filetypeIcon, { 'ActiveBg', 'black' } },
      { components.filetype, { 'white', 'black' } },
      { '', { 'InactiveFg', 'black' } },
      { components.progress, { 'ActiveBg', 'InactiveFg' } },
      { '', { 'ActiveBg', 'InactiveFg' } },
      { components.lineCol, { 'black', 'ActiveBg' } },
    }

    local defaultStatusLine = {
      filetypes = { 'default' },
      active = sections,
      inactive = sections,
    }

    require('windline').setup({
      statuslines = {
        defaultStatusLine,
      },
    })
  end,
}
