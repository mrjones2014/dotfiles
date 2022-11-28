return {
  localplugin('ldelossa/nvim-ide'),
  event = 'VimEnter',
  config = function()
    local explorer = require('ide.components.explorer')
    local outline = require('ide.components.outline')
    local callhierarchy = require('ide.components.callhierarchy')
    local timeline = require('ide.components.timeline')
    local terminal = require('ide.components.terminal')
    local terminalbrowser = require('ide.components.terminal.terminalbrowser')
    local changes = require('ide.components.changes')
    local commits = require('ide.components.commits')
    local branches = require('ide.components.branches')
    local bookmarks = require('ide.components.bookmarks')
    require('ide').setup({
      components = {
        [explorer.Name] = { list_directories_first = true, show_file_permissions = false },
      },
      panel_groups = {
        explorer = { explorer.Name, outline.Name, bookmarks.Name, callhierarchy.Name, terminalbrowser.Name },
      },
    })
  end,
}
