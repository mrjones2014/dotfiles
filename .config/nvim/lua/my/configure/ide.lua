return {
  localplugin('ldelossa/nvim-ide'),
  event = 'VimEnter',
  config = function()
    local explorer = require('ide.components.explorer')
    local outline = require('ide.components.outline')
    local bufferlist = require('ide.components.bufferlist')
    local changes = require('ide.components.changes')
    local commits = require('ide.components.commits')
    require('ide').setup({
      components = {
        [explorer.Name] = {
          list_directories_first = true,
          show_file_permissions = false,
          keymaps = {
            hide = '<NOP>',
          },
        },
        [outline.Name] = {
          keymaps = {
            hide = '<NOP>',
          },
        },
      },
      panel_groups = {
        explorer = { bufferlist.Name, explorer.Name, outline.Name },
        git = { changes.Name, commits.Name },
      },
    })
  end,
}
