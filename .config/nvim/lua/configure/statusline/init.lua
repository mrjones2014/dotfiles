return {
  'windwp/windline.nvim',
  before = 'indent-blankline.nvim',
  config = function()
    local components = require('configure.statusline.components')
    local sections = {
      { components.mode, { 'black', 'ActiveBg' } },
      { '', { 'ActiveBg', 'InactiveFg' } },
      {
        require('windline.components.git').git_branch({ icon = require('nvim-nonicons').get('git-branch') }),
        { 'ActiveBg', 'InactiveFg' },
      },
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

    vim.cmd('WindLineFloatToggle')
  end,
}
