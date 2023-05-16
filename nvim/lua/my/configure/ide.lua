return {
  'ldelossa/nvim-ide',
  cmd = 'Workspace',
  config = function()
    local explorer = require('ide.components.explorer')
    local outline = require('ide.components.outline')
    local bufferlist = require('ide.components.bufferlist')

    -- I don't want to close individual components, only hide the whole sidebars
    local keymap_overrides = { keymaps = { hide = '<NOP>' } }

    require('ide').setup({
      components = {
        [explorer.Name] = vim.tbl_extend('keep', {
          list_directories_first = true,
          show_file_permissions = false,
          keymaps = require('ide.components.explorer.presets').nvim_tree,
        }, keymap_overrides),
        [outline.Name] = keymap_overrides,
        [bufferlist.Name] = vim.tbl_extend('keep', {
          default_height = 10,
        }, keymap_overrides),
      },
      panel_groups = {
        explorer = {},
        git = { bufferlist.Name, explorer.Name, outline.Name },
      },
    })
  end,
}
