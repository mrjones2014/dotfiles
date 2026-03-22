local M = {}

local function setup_highlights()
  local function hl_fg(name)
    local hl = vim.api.nvim_get_hl(0, { name = name, link = false })
    return hl.fg
  end

  local function hl_bg(name)
    local hl = vim.api.nvim_get_hl(0, { name = name, link = false })
    return hl.bg
  end

  local statusline_bg = hl_bg('StatusLine')
  local surface = hl_bg('Visual')
  local accent = hl_fg('Function')
  local cyan = hl_fg('Type')
  local green = hl_fg('String')
  local dimmed = hl_fg('Comment')

  vim.api.nvim_set_hl(0, 'CcuiModeSep', { fg = accent, bg = statusline_bg })
  vim.api.nvim_set_hl(0, 'CcuiMode', { fg = statusline_bg, bg = accent, bold = true })

  vim.api.nvim_set_hl(0, 'CcuiAdapter', { fg = cyan, bg = surface })
  vim.api.nvim_set_hl(0, 'CcuiAdapterSep', { fg = surface, bg = statusline_bg })

  vim.api.nvim_set_hl(0, 'CcuiModel', { fg = green, bg = statusline_bg })

  vim.api.nvim_set_hl(0, 'CcuiSpinner', { fg = dimmed, bg = statusline_bg, bold = true })

  vim.api.nvim_set_hl(0, 'CcuiPlaceholder', { fg = dimmed, italic = true })
  vim.api.nvim_set_hl(0, 'CcuiPlaceholderKey', { fg = accent, bold = true })
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
  require('codecompanion-nui.completion').setup()
end

function M.focus_input()
  require('codecompanion-nui.layout').focus_input()
end

---@return boolean
function M.is_visible()
  return require('codecompanion-nui.layout').is_visible()
end

return M
