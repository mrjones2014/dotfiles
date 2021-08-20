local M = {}

function M.tokyonight()
  local sidebarColor = '#2a2a28'
  local backgroundColor = '#212222'
  vim.g.tokyonight_style = 'night'
  vim.g.tokyonight_sidebars = { 'packer', 'NvimTree', 'Trouble' }
  vim.g.tokyonight_colors = {
    bg = backgroundColor,
    bg_dark = backgroundColor,
    bg_sidebar = sidebarColor,
    bg_float = sidebarColor,
  }

  vim.cmd('colorscheme tokyonight')
end

function M.catppuccino()
  require('catppuccino').setup({
    integrations = {
      nvimtree = true,
      telescope = true,
      dashboard = true,
      bufferline = true,
      lsp_trouble = true,
      lsp_saga = true,
      indent_blankline = true,
    },
  })
  vim.cmd('colorscheme catppuccino')
end

function M.pickThemeWithTelescope()
  local pickers = require('telescope.pickers')
  local finders = require('telescope.finders')
  local sorters = require('telescope.sorters')
  local themes = require('modules.utils').filter(vim.tbl_keys(M), function(_, value)
    return value ~= 'configureTheme' and value ~= 'pickThemeWithTelescope'
  end)
  pickers
    :new({
      prompt_title = 'Themes',
      finder = finders.new_table(themes),
      sorter = sorters.get_generic_fuzzy_sorter(),
      attach_mappings = function(_, map)
        map('i', '<CR>', function(buffnr)
          M.configureTheme(require('telescope.actions.state').get_selected_entry()[1])
          require('telescope.actions').close(buffnr)
        end)
        return true
      end,
    })
    :find()
end

function M.configureTheme(themeName)
  local themeHandler = M[themeName]
  assert(themeHandler, 'No such theme: ' .. themeName)
  themeHandler()
end

vim.cmd('command! Themes :lua require("modules.theme-manager").pickThemeWithTelescope()')

return M
