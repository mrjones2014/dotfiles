return {
  localplugin('ldelossa/nvim-ide'),
  event = 'User DashboardLeave',
  config = function()
    local explorer = require('ide.components.explorer')
    local outline = require('ide.components.outline')
    local bufferlist = require('ide.components.bufferlist')
    local changes = require('ide.components.changes')
    local commits = require('ide.components.commits')

    -- I don't want to close individual components, only hide the whole sidebars
    local keymap_overrides = { keymaps = { hide = '<NOP>' } }

    require('ide').setup({
      components = {
        [explorer.Name] = vim.tbl_extend('keep', {
          list_directories_first = true,
          show_file_permissions = false,
        }, keymap_overrides),
        [outline.Name] = keymap_overrides,
        [bufferlist.Name] = keymap_overrides,
      },
      panel_groups = {
        explorer = { bufferlist.Name, explorer.Name, outline.Name },
        git = { changes.Name, commits.Name },
      },
      workspaces = {
        auto_close = false,
      },
    })
  end,
}
