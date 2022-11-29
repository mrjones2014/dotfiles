return {
  localplugin('ldelossa/nvim-ide'),
  event = 'VimEnter',
  config = function()
    local explorer = require('ide.components.explorer')
    local outline = require('ide.components.outline')
    local callhierarchy = require('ide.components.callhierarchy')
    local bookmarks = require('ide.components.bookmarks')
    local bufferlist = require('ide.components.bufferlist')
    require('ide').setup({
      components = {
        [explorer.Name] = { list_directories_first = true, show_file_permissions = false },
      },
      panel_groups = {
        explorer = { bufferlist.Name, explorer.Name, outline.Name, callhierarchy.Name },
      },
    })
  end,
}
