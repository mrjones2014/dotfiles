local M = {}

local function setup_highlights()
  local ok, colors = pcall(function()
    return require('tokyonight.colors').setup()
  end)
  if not ok then
    return
  end

  local bg_gutter = colors.fg_gutter
  local bg_surface1 = colors.dark3
  local bg_surface2 = colors.blue7

  vim.api.nvim_set_hl(0, 'CcuiModeSep', { fg = bg_surface2, bg = bg_gutter })
  vim.api.nvim_set_hl(0, 'CcuiMode', { fg = colors.blue, bg = bg_surface2, bold = true })

  vim.api.nvim_set_hl(0, 'CcuiAdapter', { fg = colors.cyan, bg = bg_surface1 })
  vim.api.nvim_set_hl(0, 'CcuiAdapterSep', { fg = bg_surface1, bg = bg_gutter })

  vim.api.nvim_set_hl(0, 'CcuiModel', { fg = colors.green, bg = bg_gutter })

  vim.api.nvim_set_hl(0, 'CcuiSpinner', { fg = colors.dark5, bg = bg_gutter, bold = true })

  vim.api.nvim_set_hl(0, 'CcuiPlaceholder', { fg = colors.dark5, italic = true })
  vim.api.nvim_set_hl(0, 'CcuiPlaceholderKey', { fg = colors.blue, bold = true })
end

---@param opts? table
function M.setup(opts)
  opts = opts or {}

  setup_highlights()

  vim.api.nvim_create_autocmd('ColorScheme', {
    group = vim.api.nvim_create_augroup('codecompanion-nui_colors', { clear = true }),
    callback = setup_highlights,
  })

  require('codecompanion-nui.events').setup()
end

function M.focus_input()
  require('codecompanion-nui.layout').focus_input()
end

---@return boolean
function M.is_visible()
  return require('codecompanion-nui.layout').is_visible()
end

return M
